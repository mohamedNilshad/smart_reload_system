import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/data/datasource/plan_advisor.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/data/datasource/plan_history.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/plan_advice.entity.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/plan_suggestion_input.entity.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/usage_stats.entity.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/repository/plan_suggestion.repo.dart';
import 'package:smart_reload_system/src/core/services/advice_fallback.service.dart';
import 'package:smart_reload_system/src/core/services/usage_analyzer.service.dart';

class _CacheEntry {
  final String fingerprint;
  final PlanAdviceEntity advice;
  final DateTime at;

  const _CacheEntry(this.fingerprint, this.advice, this.at);
}

class PlanSuggestionRepoImpl implements PlanSuggestionRepo {
  PlanSuggestionRepoImpl({
    required this.history,
    required this.advisor,
    required this.analyzer,
    this.fallback = const AdviceFallback(),
  });

  final PlanHistoryRemoteDataSource history;
  final PlanAdvisorRemoteDataSource advisor;
  final UsageAnalyzer analyzer;
  final AdviceFallback fallback;

  /// A saved answer is reused while the customer's history is unchanged. This
  /// keeps AI calls (and cost) low. Kept in memory for the app session.
  static const _ttl = Duration(hours: 12);

  /// "Refresh" can't trigger a new AI call more often than this.
  static const _refreshCooldown = Duration(minutes: 2);

  final _cache = <String, _CacheEntry>{};

  @override
  Future<Either<Failure, PlanAdviceEntity>> getAdvice({
    required String connectionId,
    bool forceRefresh = false,
  }) async {
    try {
      final now = DateTime.now();
      final input = await history.load(connectionId: connectionId, now: now);
      final stats = analyzer.analyze(input.history, now);

      // Too little history: no point asking the AI model.
      if (!stats.hasEnoughHistory) {
        return Right(
          PlanAdviceEntity(
            stats: stats,
            summary: 'We need at least $kMinReloadsForAdvice reloads in the last '
                '${stats.windowDays} days to suggest a better plan. '
                'You have ${stats.reloadCount} so far.',
            suggestions: const [],
            isAiGenerated: false,
            generatedAt: now,
          ),
        );
      }

      final fingerprint = _fingerprint(input);
      final cached = _cache[connectionId];
      if (cached != null && cached.fingerprint == fingerprint) {
        final age = now.difference(cached.at);
        if (age < _refreshCooldown || (!forceRefresh && age < _ttl)) {
          return Right(cached.advice);
        }
      }

      final rated = analyzer.rateCandidates(
        stats: stats,
        candidates: input.candidates,
      );

      if (rated.isEmpty) {
        return Right(
          PlanAdviceEntity(
            stats: stats,
            summary: fallback.summary(stats),
            suggestions: const [],
            tip: 'We could not find other packages for your provider to compare yet.',
            isAiGenerated: false,
            generatedAt: now,
          ),
        );
      }

      final advice = await _generate(
        input: input,
        stats: stats,
        rated: rated,
        now: now,
      );
      _cache[connectionId] = _CacheEntry(fingerprint, advice, now);
      return Right(advice);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  Future<PlanAdviceEntity> _generate({
    required PlanSuggestionInputEntity input,
    required UsageStatsEntity stats,
    required List<RatedCandidateEntity> rated,
    required DateTime now,
  }) async {
    try {
      final draft = await advisor.advise(input: input, stats: stats, rated: rated);
      final suggestions = _merge(draft, rated);
      if (suggestions.isNotEmpty) {
        return PlanAdviceEntity(
          stats: stats,
          summary: draft.summary.isNotEmpty ? draft.summary : fallback.summary(stats),
          suggestions: suggestions,
          tip: draft.tip,
          isAiGenerated: true,
          generatedAt: now,
        );
      }
    } on ServerException {
      // The AI service failed: show the built-in estimate instead.
    }
    return fallback.build(stats: stats, rated: rated, now: now);
  }

  /// Keeps only suggestions that point at a real candidate, attaches the
  /// app-calculated money figures, and drops duplicates. The AI model never
  /// supplies prices or savings that reach the screen.
  List<PlanSuggestionEntity> _merge(
    PlanAdviceDraft draft,
    List<RatedCandidateEntity> rated,
  ) {
    final byId = {for (final r in rated) r.candidate.id: r};
    final seen = <String>{};
    final out = <PlanSuggestionEntity>[];

    for (final s in draft.suggestions) {
      final r = byId[s.packageId];
      if (r == null || !seen.add(s.packageId)) continue;

      out.add(
        PlanSuggestionEntity(
          package: r.candidate,
          monthlyCost: r.monthlyCost,
          monthlySaving: r.monthlySaving,
          title: s.title.isEmpty ? r.candidate.name : _limit(s.title, 60),
          reason: _limit(s.reason, 300),
          confidence: switch (s.confidence) {
            'high' => SuggestionConfidence.high,
            'medium' => SuggestionConfidence.medium,
            _ => SuggestionConfidence.low,
          },
        ),
      );
      if (out.length == 3) break;
    }
    return out;
  }

  String _limit(String s, int max) => s.length <= max ? s : '${s.substring(0, max - 1)}…';

  /// Changes when the customer reloads again or the package list changes.
  String _fingerprint(PlanSuggestionInputEntity input) {
    final last = input.history.isEmpty
        ? 0
        : input.history.last.requestDate.millisecondsSinceEpoch;
    final priceSum = input.candidates.fold<double>(0, (s, c) => s + c.price);
    return '${input.history.length}:$last:${input.candidates.length}:$priceSum';
  }
}

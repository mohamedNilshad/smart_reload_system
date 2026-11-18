import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/plan_advice.entity.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/usage_stats.entity.dart';
import 'package:smart_reload_system/src/core/utils/money.util.dart';

/// Built-in suggestions with templated text. Used when the AI service is
/// unavailable (offline, quota reached, App Check problem) or returns nothing
/// usable, so the customer still sees something helpful.
class AdviceFallback {
  const AdviceFallback();

  String summary(UsageStatsEntity stats) {
    return 'You reloaded ${stats.reloadCount} '
        '${stats.reloadCount == 1 ? 'time' : 'times'} in the last '
        '${stats.windowDays} days, about ${moneyText(stats.monthlySpend)} a month.';
  }

  PlanAdviceEntity build({
    required UsageStatsEntity stats,
    required List<RatedCandidateEntity> rated,
    required DateTime now,
  }) {
    final cheaper = rated.where((r) => r.monthlySaving > 0).toList()
      ..sort((a, b) => b.monthlySaving.compareTo(a.monthlySaving));

    final picks = cheaper.isNotEmpty
        ? cheaper.take(3).toList()
        : (rated.isEmpty ? <RatedCandidateEntity>[] : [rated.first]);

    return PlanAdviceEntity(
      stats: stats,
      summary: summary(stats),
      suggestions: [
        for (var i = 0; i < picks.length; i++)
          PlanSuggestionEntity(
            package: picks[i].candidate,
            monthlyCost: picks[i].monthlyCost,
            monthlySaving: picks[i].monthlySaving,
            title: picks[i].monthlySaving > 0 ? 'Lower cost per day' : 'Closest match',
            reason: _reason(picks[i], stats),
            confidence: cheaper.isNotEmpty && i == 0
                ? SuggestionConfidence.medium
                : SuggestionConfidence.low,
          ),
      ],
      isAiGenerated: false,
      generatedAt: now,
    );
  }

  String _reason(RatedCandidateEntity r, UsageStatsEntity stats) {
    final c = r.candidate;
    return 'This package works out to ${moneyText(c.costPerDay)} per day over '
        '${c.validityDays.toStringAsFixed(c.validityDays % 1 == 0 ? 0 : 1)} days. '
        'Your reloads average about ${moneyText(stats.monthlySpend)} a month; '
        'this would be about ${moneyText(r.monthlyCost)}.';
  }
}

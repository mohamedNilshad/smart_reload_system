import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/candidate_package.entity.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/usage_stats.entity.dart';

enum SuggestionConfidence { high, medium, low }

class PlanSuggestionEntity extends Equatable {
  final CandidatePackageEntity package;

  /// Worked out by the app, not the AI model.
  final double monthlyCost;
  final double monthlySaving;

  /// Short headline and explanation (written by the AI model, or by the
  /// built-in fallback).
  final String title;
  final String reason;
  final SuggestionConfidence confidence;

  const PlanSuggestionEntity({
    required this.package,
    required this.monthlyCost,
    required this.monthlySaving,
    required this.title,
    required this.reason,
    required this.confidence,
  });

  @override
  List<Object?> get props =>
      [package, monthlyCost, monthlySaving, title, reason, confidence];
}

class PlanAdviceEntity extends Equatable {
  final UsageStatsEntity stats;
  final String summary;
  final List<PlanSuggestionEntity> suggestions;
  final String? tip;

  /// False when the AI model wasn't used (too little history, or the AI
  /// service failed and the built-in estimate was shown instead).
  final bool isAiGenerated;
  final DateTime generatedAt;

  const PlanAdviceEntity({
    required this.stats,
    required this.summary,
    required this.suggestions,
    this.tip,
    required this.isAiGenerated,
    required this.generatedAt,
  });

  bool get hasEnoughHistory => stats.hasEnoughHistory;

  @override
  List<Object?> get props =>
      [stats, summary, suggestions, tip, isAiGenerated, generatedAt];
}

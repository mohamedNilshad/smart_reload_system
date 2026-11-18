import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/candidate_package.entity.dart';

/// Minimum number of reloads in the window before suggestions are made.
const kMinReloadsForAdvice = 3;

/// What the customer's recent reloads look like, worked out in plain code
/// (never by the AI model).
class UsageStatsEntity extends Equatable {
  final int windowDays;
  final int reloadCount;
  final int packageReloads;
  final int amountReloads;
  final double totalSpent;

  /// Spend normalised to 30 days.
  final double monthlySpend;

  /// Average days between reloads; null with fewer than two reloads.
  final double? avgGapDays;

  /// Average days a connection sat without an active package between two
  /// package reloads; null when expiry dates are unknown.
  final double? avgLapseDays;

  /// Spend per day of validity across package reloads.
  final double? avgCostPerDay;

  final List<String> topPackages;
  final String? dominantPackageType;

  const UsageStatsEntity({
    required this.windowDays,
    required this.reloadCount,
    required this.packageReloads,
    required this.amountReloads,
    required this.totalSpent,
    required this.monthlySpend,
    this.avgGapDays,
    this.avgLapseDays,
    this.avgCostPerDay,
    this.topPackages = const [],
    this.dominantPackageType,
  });

  bool get hasEnoughHistory => reloadCount >= kMinReloadsForAdvice;

  @override
  List<Object?> get props => [
        windowDays,
        reloadCount,
        packageReloads,
        amountReloads,
        totalSpent,
        monthlySpend,
        avgGapDays,
        avgLapseDays,
        avgCostPerDay,
        topPackages,
        dominantPackageType,
      ];
}

/// A candidate package with its projected cost, worked out in plain code.
class RatedCandidateEntity extends Equatable {
  final CandidatePackageEntity candidate;

  /// Cost per 30 days if the customer bought only this package.
  final double monthlyCost;

  /// Current monthly spend minus [monthlyCost]. Negative means it costs more.
  final double monthlySaving;

  const RatedCandidateEntity({
    required this.candidate,
    required this.monthlyCost,
    required this.monthlySaving,
  });

  @override
  List<Object?> get props => [candidate, monthlyCost, monthlySaving];
}

import 'dart:math' as math;

import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/candidate_package.entity.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/reload_record.entity.dart';
import 'package:smart_reload_system/src/feature/client/ai_suggest/domain/entities/usage_stats.entity.dart';

/// Pure Dart: works out how a customer reloads and which candidate packages
/// are worth showing to the AI model. All the numbers come from here, so the
/// model never has to do arithmetic.
class UsageAnalyzer {
  const UsageAnalyzer({this.windowDays = 90, this.maxCandidates = 8});

  /// How far back reloads are considered.
  final int windowDays;

  /// How many candidate packages are sent to the AI model.
  final int maxCandidates;

  UsageStatsEntity analyze(List<ReloadRecordEntity> history, DateTime now) {
    final since = DateTime(now.year, now.month, now.day - windowDays);
    final records = history
        .where((r) => !r.requestDate.isBefore(since))
        .toList()
      ..sort((a, b) => a.requestDate.compareTo(b.requestDate));

    if (records.isEmpty) {
      return UsageStatsEntity(
        windowDays: windowDays,
        reloadCount: 0,
        packageReloads: 0,
        amountReloads: 0,
        totalSpent: 0,
        monthlySpend: 0,
      );
    }

    // Spend per month. The window is at least 14 days so a short burst of
    // reloads isn't blown up into a huge monthly figure.
    final spanDays = _dayDiff(records.first.requestDate, now);
    final observedDays = math.min(windowDays, math.max(14, spanDays)).toDouble();
    final total = records.fold<double>(0, (s, r) => s + r.amount);

    // Days between consecutive reloads.
    final gaps = <double>[];
    for (var i = 1; i < records.length; i++) {
      gaps.add(
        records[i].requestDate.difference(records[i - 1].requestDate).inMinutes /
            1440.0,
      );
    }

    // Days without an active package between two package reloads.
    final lapses = <double>[];
    for (var i = 1; i < records.length; i++) {
      final prev = records[i - 1];
      final expire = prev.expireDate;
      if (!prev.isPackage || expire == null) continue;
      final nextStart = records[i].activatedDate ?? records[i].requestDate;
      final days = nextStart.difference(expire).inMinutes / 1440.0;
      lapses.add(days > 0 ? days : 0);
    }

    final packageRecords = records.where((r) => r.isPackage).toList();
    final priced = packageRecords.where((r) => (r.validityDays ?? 0) > 0).toList();
    final pricedSpend = priced.fold<double>(0, (s, r) => s + r.amount);
    final pricedDays = priced.fold<double>(0, (s, r) => s + r.validityDays!);

    return UsageStatsEntity(
      windowDays: windowDays,
      reloadCount: records.length,
      packageReloads: packageRecords.length,
      amountReloads: records.length - packageRecords.length,
      totalSpent: total,
      monthlySpend: total / observedDays * 30,
      avgGapDays: _mean(gaps),
      avgLapseDays: _mean(lapses),
      avgCostPerDay: pricedDays > 0 ? pricedSpend / pricedDays : null,
      topPackages: _topPackages(packageRecords),
      dominantPackageType: _dominantType(packageRecords),
    );
  }

  /// Picks the packages worth showing the AI model, with projected costs.
  List<RatedCandidateEntity> rateCandidates({
    required UsageStatsEntity stats,
    required List<CandidatePackageEntity> candidates,
  }) {
    var pool = candidates;

    // Stay with the kind of package the customer normally buys.
    final type = stats.dominantPackageType;
    if (type != null) {
      final sameType = pool.where((c) => c.packageType == type).toList();
      if (sameType.isNotEmpty) pool = sameType;
    }

    // Skip packages far smaller or larger than a typical reload.
    final typical = stats.reloadCount == 0 ? 0.0 : stats.totalSpent / stats.reloadCount;
    if (typical > 0) {
      final nearby = pool
          .where((c) => c.price >= typical * 0.5 && c.price <= typical * 4)
          .toList();
      if (nearby.length >= 3) pool = nearby;
    }

    final rated = [
      for (final c in pool)
        RatedCandidateEntity(
          candidate: c,
          monthlyCost: c.costPerDay * 30,
          monthlySaving: stats.monthlySpend - c.costPerDay * 30,
        ),
    ]..sort((a, b) => a.candidate.costPerDay.compareTo(b.candidate.costPerDay));

    return rated.take(maxCandidates).toList();
  }

  // ----------------------------------------------------------------- helpers

  double? _mean(List<double> values) =>
      values.isEmpty ? null : values.reduce((a, b) => a + b) / values.length;

  int _dayDiff(DateTime a, DateTime b) =>
      DateTime.utc(b.year, b.month, b.day)
          .difference(DateTime.utc(a.year, a.month, a.day))
          .inDays;

  List<String> _topPackages(List<ReloadRecordEntity> packageRecords) {
    final counts = <String, int>{};
    for (final r in packageRecords) {
      final name = r.packageName ?? 'Unknown package';
      counts[name] = (counts[name] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }

  /// The package type (data, voice, ...) when it makes up at least 60% of the
  /// customer's package reloads.
  String? _dominantType(List<ReloadRecordEntity> packageRecords) {
    final counts = <String, int>{};
    for (final r in packageRecords) {
      final type = r.packageType?.trim() ?? '';
      if (type.isEmpty) continue;
      counts[type] = (counts[type] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;

    final total = counts.values.fold<int>(0, (s, n) => s + n);
    final best = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return best.value / total >= 0.6 ? best.key : null;
  }
}

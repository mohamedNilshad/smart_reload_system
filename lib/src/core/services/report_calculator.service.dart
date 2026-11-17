import 'dart:math' as math;

import 'package:smart_reload_system/src/feature/vendor/report/domain/entity/report_period.entity.dart';
import 'package:smart_reload_system/src/feature/vendor/report/domain/entity/report_row.entity.dart';
import 'package:smart_reload_system/src/feature/vendor/report/domain/entity/report_summary.entity.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

enum _Granularity { day, week, month }

/// Pure Dart: turns a flat list of request rows into everything the vendor
/// dashboard shows. No Firebase, no Flutter, so it is easy to unit test.
///
/// [rows] may contain more than the selected period (the previous period for
/// comparison, every unpaid request, and requests near expiry); each report
/// filters what it needs.
class ReportCalculator {
  const ReportCalculator();

  ReportSummaryEntity build({
    required List<ReportRowEntity> rows,
    required ReportPeriodEntity period,
    required DateTime now,
  }) {
    final current = rows
        .where((r) =>
            !r.requestDate.isBefore(period.from) &&
            r.requestDate.isBefore(period.to))
        .toList();
    final previous = rows
        .where((r) =>
            !r.requestDate.isBefore(period.previousFrom) &&
            r.requestDate.isBefore(period.from))
        .toList();
    final unpaid = rows.where((r) => !r.isPaid).toList();

    final sales = _sum(current);
    final paid = _sum(current.where((r) => r.isPaid));
    final prevSales = _sum(previous);
    final prevPaid = _sum(previous.where((r) => r.isPaid));

    return ReportSummaryEntity(
      period: period,
      totalSales: sales,
      paidAmount: paid,
      outstanding: _sum(unpaid),
      requestCount: current.length,
      salesChangePct: _pct(sales, prevSales),
      paidChangePct: _pct(paid, prevPaid),
      requestsChangePct:
          _pct(current.length.toDouble(), previous.length.toDouble()),
      trend: _trend(current, period),
      providers: _breakdown(current, (r) => r.serviceProvider, sales),
      topPackages:
          _breakdown(current, (r) => r.packageName, sales, limit: 5),
      aging: _aging(unpaid, now),
      topUnpaid: _topUnpaid(unpaid, now),
      expiring: _expiring(rows, now),
    );
  }

  // ----------------------------------------------------------------- helpers

  double _sum(Iterable<ReportRowEntity> rows) =>
      rows.fold<double>(0, (sum, r) => sum + r.amount);

  double? _pct(double current, double previous) =>
      previous == 0 ? null : (current - previous) / previous * 100;

  /// Calendar days from [a] to [b] (negative if [b] is earlier).
  int _dayDiff(DateTime a, DateTime b) =>
      DateTime.utc(b.year, b.month, b.day)
          .difference(DateTime.utc(a.year, a.month, a.day))
          .inDays;

  String _connectionKey(ReportRowEntity r) =>
      r.connectionId.isEmpty ? r.id : r.connectionId;

  // ------------------------------------------------------------------- trend

  List<TrendPoint> _trend(List<ReportRowEntity> rows, ReportPeriodEntity p) {
    final g = p.days <= 31
        ? _Granularity.day
        : p.days <= 120
            ? _Granularity.week
            : _Granularity.month;

    DateTime bucketStart(DateTime d) => switch (g) {
          _Granularity.day => DateTime(d.year, d.month, d.day),
          _Granularity.week => DateTime(d.year, d.month, d.day - (d.weekday - 1)),
          _Granularity.month => DateTime(d.year, d.month),
        };

    DateTime nextBucket(DateTime s) => switch (g) {
          _Granularity.day => DateTime(s.year, s.month, s.day + 1),
          _Granularity.week => DateTime(s.year, s.month, s.day + 7),
          _Granularity.month => DateTime(s.year, s.month + 1),
        };

    String label(DateTime d) => g == _Granularity.month
        ? _months[d.month - 1]
        : '${d.day} ${_months[d.month - 1]}';

    // Pre-create every bucket so quiet days still show as empty bars.
    final amounts = <DateTime, double>{};
    final counts = <DateTime, int>{};
    for (var s = bucketStart(p.from); s.isBefore(p.to); s = nextBucket(s)) {
      amounts[s] = 0;
      counts[s] = 0;
    }
    for (final r in rows) {
      final key = bucketStart(r.requestDate);
      if (amounts.containsKey(key)) {
        amounts[key] = amounts[key]! + r.amount;
        counts[key] = counts[key]! + 1;
      }
    }

    return [
      for (final key in amounts.keys)
        TrendPoint(
          label: label(key),
          start: key,
          amount: amounts[key]!,
          count: counts[key]!,
        ),
    ];
  }

  // --------------------------------------------------------------- breakdown

  List<BreakdownItem> _breakdown(
    List<ReportRowEntity> rows,
    String Function(ReportRowEntity) keyOf,
    double total, {
    int? limit,
  }) {
    final amounts = <String, double>{};
    final counts = <String, int>{};
    for (final r in rows) {
      final k = keyOf(r);
      amounts[k] = (amounts[k] ?? 0) + r.amount;
      counts[k] = (counts[k] ?? 0) + 1;
    }

    final items = [
      for (final k in amounts.keys)
        BreakdownItem(
          name: k,
          amount: amounts[k]!,
          count: counts[k]!,
          share: total == 0 ? 0 : amounts[k]! / total,
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    return limit == null || items.length <= limit
        ? items
        : items.sublist(0, limit);
  }

  // ------------------------------------------------------------------ ageing

  List<AgingBucket> _aging(List<ReportRowEntity> unpaid, DateTime now) {
    final amounts = [0.0, 0.0, 0.0];
    final counts = [0, 0, 0];
    for (final r in unpaid) {
      final age = _dayDiff(r.requestDate, now);
      final i = age <= 7 ? 0 : (age <= 30 ? 1 : 2);
      amounts[i] += r.amount;
      counts[i] += 1;
    }
    const labels = ['0–7 days', '8–30 days', '31+ days'];
    return [
      for (var i = 0; i < 3; i++)
        AgingBucket(label: labels[i], amount: amounts[i], count: counts[i]),
    ];
  }

  List<UnpaidConnection> _topUnpaid(List<ReportRowEntity> unpaid, DateTime now) {
    final groups = <String, List<ReportRowEntity>>{};
    for (final r in unpaid) {
      groups.putIfAbsent(_connectionKey(r), () => []).add(r);
    }

    final items = [
      for (final g in groups.values)
        UnpaidConnection(
          connectionName: g.first.connectionName,
          connectionNumber: g.first.connectionNumber,
          amount: _sum(g),
          count: g.length,
          oldestDays:
              g.map((r) => _dayDiff(r.requestDate, now)).reduce(math.max),
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    return items.take(5).toList();
  }

  // ---------------------------------------------------------------- expiring

  /// A connection's coverage ends at the latest `expireDate` among its
  /// requests, so a renewal that is already in [rows] correctly hides the
  /// older package that is about to lapse.
  List<ExpiringConnection> _expiring(List<ReportRowEntity> rows, DateTime now) {
    final latest = <String, ReportRowEntity>{};
    for (final r in rows) {
      final e = r.expireDate;

      if (e == null) continue;
      final key = _connectionKey(r);
      final existing = latest[key];
      if (existing == null || e.isAfter(existing.expireDate!)) {
        latest[key] = r;
      }
    }

    final items = [
      for (final r in latest.values)
        if (_dayDiff(now, r.expireDate!) >= 0 && _dayDiff(now, r.expireDate!) <= 7)
          ExpiringConnection(
            connectionName: r.connectionName,
            connectionNumber: r.connectionNumber,
            packageName: r.packageName,
            expireDate: r.expireDate!,
            daysLeft: _dayDiff(now, r.expireDate!),
          ),
    ]..sort((a, b) => a.expireDate.compareTo(b.expireDate));


    return items.take(20).toList();
  }
}

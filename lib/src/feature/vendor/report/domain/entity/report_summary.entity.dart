import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/vendor/report/domain/entity/report_period.entity.dart';

class TrendPoint extends Equatable {
  final String label;
  final DateTime start;
  final double amount;
  final int count;

  const TrendPoint({
    required this.label,
    required this.start,
    required this.amount,
    required this.count,
  });

  @override
  List<Object?> get props => [label, start, amount, count];
}

class BreakdownItem extends Equatable {
  final String name;
  final double amount;
  final int count;

  /// Fraction of the period's total sales, 0..1.
  final double share;

  const BreakdownItem({
    required this.name,
    required this.amount,
    required this.count,
    required this.share,
  });

  @override
  List<Object?> get props => [name, amount, count, share];
}

class AgingBucket extends Equatable {
  final String label;
  final double amount;
  final int count;

  const AgingBucket({
    required this.label,
    required this.amount,
    required this.count,
  });

  @override
  List<Object?> get props => [label, amount, count];
}

class UnpaidConnection extends Equatable {
  final String connectionName;
  final String connectionNumber;
  final double amount;
  final int count;
  final int oldestDays;

  const UnpaidConnection({
    required this.connectionName,
    required this.connectionNumber,
    required this.amount,
    required this.count,
    required this.oldestDays,
  });

  @override
  List<Object?> get props =>
      [connectionName, connectionNumber, amount, count, oldestDays];
}

class ExpiringConnection extends Equatable {
  final String connectionName;
  final String connectionNumber;
  final String packageName;
  final DateTime expireDate;

  /// Calendar days from today; 0 means it expires today.
  final int daysLeft;

  const ExpiringConnection({
    required this.connectionName,
    required this.connectionNumber,
    required this.packageName,
    required this.expireDate,
    required this.daysLeft,
  });

  @override
  List<Object?> get props =>
      [connectionName, connectionNumber, packageName, expireDate, daysLeft];
}

class ReportSummaryEntity extends Equatable {
  final ReportPeriodEntity period;

  final double totalSales;
  final double paidAmount;

  /// Everything unpaid right now, regardless of the selected period.
  final double outstanding;
  final int requestCount;

  /// Percent change against the previous period; null when there is no
  /// previous data to compare with.
  final double? salesChangePct;
  final double? paidChangePct;
  final double? requestsChangePct;

  final List<TrendPoint> trend;
  final List<BreakdownItem> providers;
  final List<BreakdownItem> topPackages;
  final List<AgingBucket> aging;
  final List<UnpaidConnection> topUnpaid;
  final List<ExpiringConnection> expiring;

  const ReportSummaryEntity({
    required this.period,
    required this.totalSales,
    required this.paidAmount,
    required this.outstanding,
    required this.requestCount,
    required this.salesChangePct,
    required this.paidChangePct,
    required this.requestsChangePct,
    required this.trend,
    required this.providers,
    required this.topPackages,
    required this.aging,
    required this.topUnpaid,
    required this.expiring,
  });

  @override
  List<Object?> get props => [
        period,
        totalSales,
        paidAmount,
        outstanding,
        requestCount,
        salesChangePct,
        paidChangePct,
        requestsChangePct,
        trend,
        providers,
        topPackages,
        aging,
        topUnpaid,
        expiring,
      ];
}

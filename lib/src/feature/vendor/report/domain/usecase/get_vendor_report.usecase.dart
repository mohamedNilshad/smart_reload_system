import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/vendor/report/domain/entity/report_period.entity.dart';
import 'package:smart_reload_system/src/feature/vendor/report/domain/entity/report_summary.entity.dart';
import 'package:smart_reload_system/src/feature/vendor/report/domain/repository/vendor_reports.repo.dart';

class GetVendorReportUseCase {
  final VendorReportsRepo repo;
  GetVendorReportUseCase(this.repo);

  Future<Either<Failure, ReportSummaryEntity>> call({
    required String vendorId,
    required ReportPeriodEntity period,
  }) {
    return repo.getReport(vendorId: vendorId, period: period);
  }
}

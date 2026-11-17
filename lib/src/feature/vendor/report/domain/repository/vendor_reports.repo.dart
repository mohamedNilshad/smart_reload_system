import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/vendor/report/domain/entity/report_period.entity.dart';
import 'package:smart_reload_system/src/feature/vendor/report/domain/entity/report_summary.entity.dart';

abstract class VendorReportsRepo {
  Future<Either<Failure, ReportSummaryEntity>> getReport({
    required String vendorId,
    required ReportPeriodEntity period,
  });
}

import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/services/report_calculator.service.dart';
import 'package:smart_reload_system/src/feature/vendor/report/data/datasource/vendor_reports.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/vendor/report/domain/entity/report_period.entity.dart';
import 'package:smart_reload_system/src/feature/vendor/report/domain/entity/report_summary.entity.dart';
import 'package:smart_reload_system/src/feature/vendor/report/domain/repository/vendor_reports.repo.dart';

class VendorReportsRepoImpl implements VendorReportsRepo {
  final VendorReportsRemoteDataSource remote;
  final ReportCalculator calculator;

  VendorReportsRepoImpl({required this.remote, required this.calculator});

  @override
  Future<Either<Failure, ReportSummaryEntity>> getReport({
    required String vendorId,
    required ReportPeriodEntity period,
  }) async {
    try {
      final now = DateTime.now();
      final rows = await remote.fetchRows(
        vendorId: vendorId,
        from: period.previousFrom, // also load the previous period to compare
        to: period.to,
        now: now,
      );
      return Right(calculator.build(rows: rows, period: period, now: now));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}

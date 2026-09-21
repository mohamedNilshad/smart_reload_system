import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';

abstract class PaymentClientRepo {
  Future<Either<Failure, bool>> createPayment({
    required double lastPaidAmount,
    required String clientVendorId,
    required DateTime lastPaidDate,
    required List<String> reqPackageIdList,

    required String vendorId,
    required double vendorComAmount,

    required String paymentRefNumber,
    required String invoiceNo,
  });

  Future<Either<Failure, List<PackageRequestModel>>> fetchPayables({required String clientVendorId});
}

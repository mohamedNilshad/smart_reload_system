import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/repository/payment.client.repo.dart';

class CreatePaymentUseCase {
  final PaymentClientRepo repo;

  CreatePaymentUseCase(this.repo);

  Future<Either<Failure, bool>> call({
    required double lastPaidAmount,
    required String clientVendorId,
    required DateTime lastPaidDate,
    required List<String> reqPackageIdList,

    required String vendorId,
    required double vendorComAmount,

    required String paymentRefNumber,
    required String invoiceNo,
  }) {
    return repo.createPayment(
      lastPaidDate: lastPaidDate,
      lastPaidAmount: lastPaidAmount,
      clientVendorId: clientVendorId,
      reqPackageIdList: reqPackageIdList,
      vendorId: vendorId,
      vendorComAmount: vendorComAmount,
      paymentRefNumber: paymentRefNumber,
      invoiceNo: invoiceNo
    );
  }
}

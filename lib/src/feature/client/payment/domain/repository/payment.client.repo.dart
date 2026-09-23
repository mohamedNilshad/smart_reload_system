import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/data/model/Invoice_pdf_data.model.dart';

abstract class PaymentClientRepo {
  Future<Either<Failure, bool>> createPayment({
    required double lastPaidAmount,
    required String clientVendorId,
    required DateTime lastPaidDate,
    required List<String> reqPackageIdList,

    required String vendorId,
    required double vendorComAmount,

    required String paymentRefNumber,
    required InvoicePdfData invoiceData,
  });

  Future<Either<Failure, Map<String, dynamic>>> fetchPayables({required String clientVendorId});
}

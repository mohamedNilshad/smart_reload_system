import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/data/model/Invoice_pdf_data.model.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/payment/data/datasource/payment.client.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/client/payment/data/model/paid_invoice_data.model.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/repository/payment.client.repo.dart';

class PaymentClientRepoImpl implements PaymentClientRepo {
  final PaymentClientRemoteDataSource remoteDataSource;

  PaymentClientRepoImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, bool>> createPayment({
    required double lastPaidAmount,
    required String clientVendorId,
    required DateTime lastPaidDate,
    required List<String> reqPackageIdList,

    required String vendorId,
    required double vendorComAmount,

    required String paymentRefNumber,
    required InvoicePdfData invoiceData,
  }) async {
    try {
      final payment = await remoteDataSource.createPayment(
        lastPaidAmount: lastPaidAmount,
        clientVendorId: clientVendorId,
        lastPaidDate: lastPaidDate,
        reqPackageIdList: reqPackageIdList,
        vendorId: vendorId,
        vendorComAmount: vendorComAmount,
        paymentRefNumber: paymentRefNumber,
        invoiceData: invoiceData,
      );
      return Right(payment);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> fetchPayables({required String clientVendorId}) async {
    try {
      final result = await remoteDataSource.fetchPayables(clientVendorId: clientVendorId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<PaidInvoiceDataModel>>> fetchPaidInvoices({required String clientVendorId}) async {
    try {
      final result = await remoteDataSource.fetchPaidInvoices(clientVendorId: clientVendorId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}

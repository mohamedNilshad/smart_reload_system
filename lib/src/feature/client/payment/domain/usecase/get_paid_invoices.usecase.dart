import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/usecase/usecase.dart';
import 'package:smart_reload_system/src/feature/client/payment/data/model/paid_invoice_data.model.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/repository/payment.client.repo.dart';

class GetPaidInvoicesUsecase implements UseCase<List<PaidInvoiceDataModel>, String> {
  final PaymentClientRepo repository;

  GetPaidInvoicesUsecase(this.repository);

  @override
  Future<Either<Failure, List<PaidInvoiceDataModel>>> call(String clientVendorId) {
    return repository.fetchPaidInvoices(clientVendorId: clientVendorId);
  }
}

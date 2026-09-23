import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/usecase/usecase.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/repository/payment.client.repo.dart';

class GetPayableDetailsUseCase implements UseCase<Map<String, dynamic>, String> {
  final PaymentClientRepo repository;

  GetPayableDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String clientVendorId) {
    return repository.fetchPayables(clientVendorId: clientVendorId);
  }
}

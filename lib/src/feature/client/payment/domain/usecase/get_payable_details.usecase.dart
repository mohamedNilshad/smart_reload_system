import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/usecase/usecase.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/repository/payment.client.repo.dart';

class GetPayableDetailsUseCase implements UseCase<List<PackageRequestModel>, String> {
  final PaymentClientRepo repository;

  GetPayableDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PackageRequestModel>>> call(String clientVendorId) {
    return repository.fetchPayables(clientVendorId: clientVendorId);
  }
}

import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/usecase/usecase.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/repository/home.repo.dart';

class GetActivatedPackagesUseCase implements UseCase<List<PackageRequestModel>, String> {
  final HomeRepo repository;

  GetActivatedPackagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<PackageRequestModel>>> call(String connectionId) {
    return repository.getActivatedPackages(connectionId);
  }
}

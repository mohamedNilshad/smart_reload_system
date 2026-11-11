import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';
import 'package:smart_reload_system/src/feature/vendor/home/domain/repository/home.repo.vendor.dart';

class ActivatePackageRequestUseCase {
  final HomeRepoV repo;

  ActivatePackageRequestUseCase(this.repo);

  Future<Either<Failure, bool>> call(PackageRequestModel packageRequestModel) {
    return repo.activatePackageRequest(packageRequestModel);
  }
}

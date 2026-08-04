import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/repository/home.repo.dart';

class RequestPackageUseCase {
  final HomeRepo repo;
  RequestPackageUseCase(this.repo);

  Future<Either<Failure, bool>> call({required PackageRequestModel packageRequestModel}) {
    return repo.requestPackage(packageRequestModel);
  }
}
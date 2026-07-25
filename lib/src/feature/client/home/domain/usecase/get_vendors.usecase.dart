import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/vendor.model.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/repository/home.repo.dart';

class GetVendorsUseCase {
  final HomeRepo repo;

  GetVendorsUseCase(this.repo);

  Future<Either<Failure, List<VendorModel>>> call() {
    return repo.getVendors();
  }
}

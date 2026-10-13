import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/vendor/home/domain/repository/home.repo.vendor.dart';

class GetClientsUseCase {
  final HomeRepoV repo;

  GetClientsUseCase(this.repo);

  Future<Either<Failure, Map<String, dynamic>>> call() {
    return repo.getClients();
  }
}

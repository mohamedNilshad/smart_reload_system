import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/usecase/usecase.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/repository/home.repo.dart';

class GetConnectionsUseCase implements UseCase<List<ConnectionModel>, String> {
  final HomeRepo repository;

  GetConnectionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ConnectionModel>>> call(String clientVendorId) {
    return repository.getConnections(clientVendorId);
  }
}

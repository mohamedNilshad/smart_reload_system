import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/repository/home.repo.dart';

class AddNewConnectionUseCase {
  final HomeRepo repo;
  AddNewConnectionUseCase(this.repo);

  Future<Either<Failure, bool>> call({required ConnectionModel connectionModel}) {
    return repo.addNewConnection(connectionModel);
  }
}
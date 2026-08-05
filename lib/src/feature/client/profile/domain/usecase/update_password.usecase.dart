import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/profile/domain/repository/profile.repo.dart';

class UpdatePasswordUseCase {
  final ProfileRepo repo;
  UpdatePasswordUseCase(this.repo);

  Future<Either<Failure, void>> call({required String password}){
    return repo.updatePassword(password: password);
  }
}

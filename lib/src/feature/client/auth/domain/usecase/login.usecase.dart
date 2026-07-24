import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/entity/client.entity.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/repository/auth.repo.dart';

class LoginUseCase {
  final AuthRepo repo;
  LoginUseCase(this.repo);

  Future<Either<Failure, UserEntity>> call({
    required String phoneNumber,
    required String password,
  }) {
    return repo.login(phoneNumber: phoneNumber, password: password);
  }
}
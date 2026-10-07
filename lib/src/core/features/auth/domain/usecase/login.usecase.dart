import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/domain/entity/user.entity.dart';
import 'package:smart_reload_system/src/core/features/auth/domain/repository/auth.repo.dart';

class LoginUseCase {
  final AuthRepo repo;
  LoginUseCase(this.repo);

  Future<Either<Failure, UserEntity>> call({
    required String phoneNumber,
    required String password,
    required String role,
  }) {
    return repo.login(phoneNumber: phoneNumber, password: password, role: role);
  }
}
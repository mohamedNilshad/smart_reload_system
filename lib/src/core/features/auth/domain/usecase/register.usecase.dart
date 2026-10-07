import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/domain/entity/user.entity.dart';
import 'package:smart_reload_system/src/core/features/auth/domain/repository/auth.repo.dart';

class RegisterUseCase {
  final AuthRepo repo;
  RegisterUseCase(this.repo);

  Future<Either<Failure, UserEntity>> call({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String nic,
    required String password,
  }) {
    return repo.register(
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
      nic: nic,
      password: password,
    );
  }
}
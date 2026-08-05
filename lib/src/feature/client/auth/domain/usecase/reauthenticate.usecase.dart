import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/repository/auth.repo.dart';

class ReauthenticateUseCase {
  final AuthRepo repo;
  ReauthenticateUseCase(this.repo);

  Future<Either<Failure, void>> call(String password) => repo.reauthenticate(password);
}
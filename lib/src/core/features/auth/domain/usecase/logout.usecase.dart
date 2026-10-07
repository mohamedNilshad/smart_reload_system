import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/features/auth/domain/repository/auth.repo.dart';

class LogoutUseCase {
  final AuthRepo repo;
  LogoutUseCase(this.repo);

  Future<Either<Failure, void>> call() => repo.logout();
}
import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/features/auth/domain/repository/auth.repo.dart';

class VerifyEmailUseCase {
  final AuthRepo repo;
  VerifyEmailUseCase(this.repo);

  Future<Either<Failure, bool>> call({required String email}) {
    return repo.forgotPassword(email);
  }
}
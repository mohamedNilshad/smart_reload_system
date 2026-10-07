import 'package:smart_reload_system/src/core/features/auth/domain/repository/auth.repo.dart';

class ClearCachedUserUseCase {
  final AuthRepo repo;
  ClearCachedUserUseCase(this.repo);

  Future<void> call() => repo.clearCachedUser();
}
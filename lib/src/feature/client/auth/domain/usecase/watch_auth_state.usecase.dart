
import 'package:smart_reload_system/src/feature/client/auth/domain/entity/client.entity.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/repository/auth.repo.dart';

class WatchAuthStateUseCase {
  final AuthRepo repo;
  WatchAuthStateUseCase(this.repo);

  Stream<UserEntity?> call() => repo.authStateChanges;
}
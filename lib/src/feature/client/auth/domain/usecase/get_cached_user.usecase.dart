import 'package:smart_reload_system/src/feature/client/auth/domain/entity/client.entity.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/repository/auth.repo.dart';

class GetCachedUserUseCase {
  final AuthRepo repo;
  GetCachedUserUseCase(this.repo);

  Future<UserEntity?> call() => repo.getCachedUser();
}
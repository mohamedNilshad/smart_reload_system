import 'package:smart_reload_system/src/core/domain/entity/user.entity.dart';
import 'package:smart_reload_system/src/core/features/auth/domain/repository/auth.repo.dart';

class UpdateCachedUserUseCase {
  final AuthRepo repo;
  UpdateCachedUserUseCase(this.repo);

  Future<void> call(UserEntity user) => repo.updateCachedUser(user);
}
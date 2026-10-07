import 'package:smart_reload_system/src/core/domain/entity/user.entity.dart';
import 'package:smart_reload_system/src/core/features/auth/domain/repository/auth.repo.dart';

class WatchUserRealtimeUseCase {
  final AuthRepo repo;
  WatchUserRealtimeUseCase(this.repo);

  Stream<UserEntity?> call(String uid) {
    return repo.watchUser(uid);
  }
}
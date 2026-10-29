import 'package:smart_reload_system/src/core/features/notification/domain/repository/notification.repo.dart';

class WatchUnreadCountUseCase {
  final NotificationRepo repo;
  WatchUnreadCountUseCase(this.repo);

  Stream<int> call(String uid) => repo.watchUnreadCount(uid);
}
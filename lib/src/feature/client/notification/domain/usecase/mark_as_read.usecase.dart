import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/notification/domain/repository/notification.repo.dart';

class MarkAsReadUseCase {
  final NotificationRepo repo;
  MarkAsReadUseCase(this.repo);

  Future<Either<Failure, void>> call({required String uid, required String notificationId}) {
    return repo.markAsRead(uid: uid, notificationId: notificationId);
  }
}
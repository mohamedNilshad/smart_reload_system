import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/feature/client/notification/domain/entity/notification.entity.dart';

abstract class NotificationRemoteDataSource {
  Stream<int> watchUnreadCount(String uid);
  Future<List<NotificationEntity>> getNotifications(String uid);
  Future<void> markAsRead({required String uid, required String notificationId});
  Future<void> markAllAsRead(String uid);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore firestore;
  NotificationRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      firestore.collection('users').doc(uid).collection('notifications');

  @override
  Stream<int> watchUnreadCount(String uid) {
    // Real-time listener on the filtered query itself — Firestore's count()
    // aggregation doesn't support live listeners, so we stream the actual
    // matching docs. Fine here since unread counts are small.
    return _collection(uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  @override
  Future<List<NotificationEntity>> getNotifications(String uid) async {
    try {
      final snapshot = await _collection(uid).orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) => NotificationEntity.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to load notifications.');
    }
  }

  @override
  Future<void> markAsRead({required String uid, required String notificationId}) async {
    try {
      await _collection(uid).doc(notificationId).update({'isRead': true});
    } catch (e) {
      throw ServerException('Failed to update notification.');
    }
  }

  @override
  Future<void> markAllAsRead(String uid) async {
    try {
      final unread = await _collection(uid).where('isRead', isEqualTo: false).get();
      final batch = firestore.batch();
      for (final doc in unread.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to update notifications.');
    }
  }
}
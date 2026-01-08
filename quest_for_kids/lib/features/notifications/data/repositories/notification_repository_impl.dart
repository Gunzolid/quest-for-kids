import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/notification_model.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepositoryImpl(this._firestore);

  @override
  Future<void> sendNotification(
    String parentId,
    NotificationEntity notification,
  ) async {
    final model = NotificationModel(
      id: notification
          .id, // Usually empty on create, but we'll let Firestore gen ID if needed or use UUID
      title: notification.title,
      message: notification.message,
      timestamp: notification.timestamp,
      isRead: notification.isRead,
      type: notification.type,
      childId: notification.childId,
      relatedId: notification.relatedId,
    );

    // We use .collection().add() which generates a new ID automatically
    // But our model conversion expects to strip 'id' anyway.
    await _firestore
        .collection('users')
        .doc(parentId)
        .collection('notifications')
        .add(model.toFirestore());
  }

  @override
  Stream<List<NotificationEntity>> streamNotifications(String parentId) {
    return _firestore
        .collection('users')
        .doc(parentId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(50) // Limit to last 50 to avoid reading too much
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Future<void> markAsRead(String parentId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(parentId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead(String parentId) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('users')
        .doc(parentId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<void> deleteAllNotifications(String parentId) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('users')
        .doc(parentId)
        .collection('notifications')
        .get();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

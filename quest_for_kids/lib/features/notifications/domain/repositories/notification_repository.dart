import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  /// Send a notification to a specific parent (write to Firestore)
  Future<void> sendNotification(
    String parentId,
    NotificationEntity notification,
  );

  /// Stream notifications for a parent, ordered by time (newest first)
  Stream<List<NotificationEntity>> streamNotifications(String parentId);

  /// Mark a specific notification as read
  Future<void> markAsRead(String parentId, String notificationId);

  /// Mark all notifications as read
  Future<void> markAllAsRead(String parentId);

  /// Delete all notifications for a parent
  Future<void> deleteAllNotifications(String parentId);
}

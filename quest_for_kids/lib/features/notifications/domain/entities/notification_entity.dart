import 'package:equatable/equatable.dart';

enum NotificationType { taskCompleted, rewardRedeemed }

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;
  final String childId;
  final String? relatedId; // taskId or rewardId

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.type,
    required this.childId,
    this.relatedId,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    timestamp,
    isRead,
    type,
    childId,
    relatedId,
  ];
}

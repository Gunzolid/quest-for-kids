import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/notification_entity.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
abstract class NotificationModel
    with _$NotificationModel
    implements NotificationEntity {
  const NotificationModel._();

  const factory NotificationModel({
    required String id,
    required String title,
    required String message,
    required DateTime timestamp,
    @Default(false) bool isRead,
    required NotificationType type,
    required String childId,
    String? relatedId,
  }) = _NotificationModel;

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

  @override
  bool? get stringify => true;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel.fromJson({
      'id': doc.id,
      ...data,
      // Handle timestamp conversion
      'timestamp': (data['timestamp'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    return toJson()
      ..remove('id')
      ..['timestamp'] = Timestamp.fromDate(timestamp);
  }
}

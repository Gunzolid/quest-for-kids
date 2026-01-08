import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/task_entity.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
abstract class TaskModel with _$TaskModel implements TaskEntity {
  const TaskModel._();

  // Implements TaskEntity properties via getters in generated code
  // We need to override props to satisfy Equatable from Entity if we weren't using Freezed's equality.
  // But Freezed handles equality. However, since TaskEntity extends Equatable,
  // we might need to explicitly override props if we want Equatable's behavior,
  // or just rely on the interface.
  // Let's implement Equatable's props manually to be safe and consistent with UserEntity structure.

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    points,
    isRecurring,
    status,
    assignedToId,
    imageUrl,
  ];

  @override
  bool? get stringify => true;

  const factory TaskModel({
    required String id,
    required String title,
    required String description,
    required int points,
    @JsonKey(name: 'is_recurring') required bool isRecurring,
    required TaskStatus status,
    @JsonKey(name: 'assigned_to_id') required String assignedToId,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'start_time') DateTime? startTime,
    @JsonKey(name: 'end_time') DateTime? endTime,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    String? parseDate(dynamic input) {
      if (input == null) return null;
      if (input is Timestamp) return input.toDate().toIso8601String();
      if (input is String) return input;
      return null;
    }

    return TaskModel.fromJson({
      'id': doc.id,
      ...data,
      'image_url': data['image_url'] ?? data['imageUrl'],
      'start_time': parseDate(data['start_time']),
      'end_time': parseDate(data['end_time']),
    });
  }
}

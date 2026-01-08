// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => _TaskModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  points: (json['points'] as num).toInt(),
  isRecurring: json['is_recurring'] as bool,
  status: $enumDecode(_$TaskStatusEnumMap, json['status']),
  assignedToId: json['assigned_to_id'] as String,
  imageUrl: json['image_url'] as String?,
  startTime: json['start_time'] == null
      ? null
      : DateTime.parse(json['start_time'] as String),
  endTime: json['end_time'] == null
      ? null
      : DateTime.parse(json['end_time'] as String),
);

Map<String, dynamic> _$TaskModelToJson(_TaskModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'points': instance.points,
      'is_recurring': instance.isRecurring,
      'status': _$TaskStatusEnumMap[instance.status]!,
      'assigned_to_id': instance.assignedToId,
      'image_url': instance.imageUrl,
      'start_time': instance.startTime?.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
    };

const _$TaskStatusEnumMap = {
  TaskStatus.pending: 'pending',
  TaskStatus.completed: 'completed',
  TaskStatus.approved: 'approved',
};

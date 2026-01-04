import 'package:equatable/equatable.dart';

enum TaskStatus { pending, completed, approved }

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final int points;
  final bool isRecurring;
  final TaskStatus status;
  final String assignedToId;
  final DateTime? startTime;
  final DateTime? endTime;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.isRecurring,
    required this.status,
    required this.assignedToId,
    this.startTime,
    this.endTime,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        points,
        isRecurring,
        status,
        assignedToId,
        startTime,
        endTime,
      ];
}

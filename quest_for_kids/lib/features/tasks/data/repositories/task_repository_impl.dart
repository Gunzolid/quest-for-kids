import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';
import '../../../../core/errors/auth_failures.dart'; // Reusing failure class for convenience

class TaskRepositoryImpl implements TaskRepository {
  final FirebaseFirestore _firestore;

  TaskRepositoryImpl(this._firestore);

  @override
  Future<void> createTask(
      TaskEntity task, String parentId, String childId) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('tasks')
          .doc();

      final taskModel = TaskModel(
        id: docRef.id,
        title: task.title,
        description: task.description,
        points: task.points,
        isRecurring: task.isRecurring,
        status: task.status,
        assignedToId: childId,
        startTime: task.startTime,
        endTime: task.endTime,
      );

      await docRef.set(taskModel.toJson()..remove('id'));
    } catch (e) {
      throw AuthFailure('Failed to create task: $e');
    }
  }

  @override
  Stream<List<TaskEntity>> getTasksForChild(String parentId, String childId) {
    return _firestore
        .collection('users')
        .doc(parentId)
        .collection('children')
        .doc(childId)
        .collection('tasks')
        .orderBy('status') // Show pending first? Or created date?
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> updateTask(
      TaskEntity task, String parentId, String childId) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('tasks')
          .doc(task.id);

      final taskModel = TaskModel(
        id: task.id,
        title: task.title,
        description: task.description,
        points: task.points,
        isRecurring: task.isRecurring,
        status: task.status,
        assignedToId: childId,
        startTime: task.startTime,
        endTime: task.endTime,
      );

      await docRef.update(taskModel.toJson()..remove('id'));
    } catch (e) {
      throw AuthFailure('Failed to update task: $e');
    }
  }

  @override
  Future<void> updateTaskStatus(
      String parentId, String childId, String taskId, TaskStatus status) async {
    try {
      await _firestore
          .collection('users')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('tasks')
          .doc(taskId)
          .update({'status': status.name}); // Enum name string
      // Note: Freezed/JsonSerializable usually uses string for enum by default if annotated correctly,
      // but here we are doing a manual patch. We should ensure the enum serialization matches.
      // TaskModel uses standard json_serializable, so it likely expects the string.
    } catch (e) {
      throw AuthFailure('Failed to update task: $e');
    }
  }

  @override
  Future<void> approveTask(
      String parentId, String childId, String taskId, int points) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final taskRef = _firestore
            .collection('users')
            .doc(parentId)
            .collection('children')
            .doc(childId)
            .collection('tasks')
            .doc(taskId);

        final childRef = _firestore
            .collection('users')
            .doc(parentId)
            .collection('children')
            .doc(childId);

        // Update task status
        transaction.update(taskRef, {'status': TaskStatus.approved.name});

        // Award points
        // We need to read the child doc first to increment, or use FieldValue.increment
        // Transaction requires read before write if we depend on value, but FieldValue.increment is simpler.
        // However, standard Firestore transaction practice: if simply incrementing, just update.
        transaction
            .update(childRef, {'currentPoints': FieldValue.increment(points)});
      });
    } catch (e) {
      throw AuthFailure('Failed to approve task: $e');
    }
  }

  @override
  Future<void> deleteTask(
      String parentId, String childId, String taskId) async {
    try {
      await _firestore
          .collection('users')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      throw AuthFailure('Failed to delete task: $e');
    }
  }
}

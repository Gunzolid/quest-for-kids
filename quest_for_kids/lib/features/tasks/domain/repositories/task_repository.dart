import '../entities/task_entity.dart';

abstract class TaskRepository {
  /// Create a new task for a specific child.
  Future<void> createTask(TaskEntity task, String parentId, String childId);

  /// Get all tasks for a specific child.
  Stream<List<TaskEntity>> getTasksForChild(String parentId, String childId);

  /// Update the status of a task (e.g. pending -> completed).
  Future<void> updateTaskStatus(
    String parentId,
    String childId,
    String taskId,
    TaskStatus status,
  );

  /// Update an existing task.
  Future<void> updateTask(TaskEntity task, String parentId, String childId);

  /// Approve a task and award points to the child (Transactional).
  Future<void> approveTask(
    String parentId,
    String childId,
    String taskId,
    int points,
  );

  /// Delete a task.
  Future<void> deleteTask(String parentId, String childId, String taskId);

  /// Delete all completed tasks for a child.
  Future<void> deleteCompletedTasks(String parentId, String childId);
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_providers.dart';
import '../widgets/add_task_dialog.dart';

class ManageTasksScreen extends ConsumerWidget {
  final String parentId;
  final String childId;
  final String childName;

  const ManageTasksScreen({
    super.key,
    required this.parentId,
    required this.childId,
    required this.childName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(
      tasksStreamProvider((parentId: parentId, childId: childId)),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Missions for $childName')),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No active missions.',
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Text('Assign a mission to start the adventure!'),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        color: Colors.blue.shade50,
                        child:
                            task.imageUrl != null && task.imageUrl!.isNotEmpty
                            ? Image.network(
                                task.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(
                                      child: Icon(
                                        task.status == TaskStatus.late
                                            ? Icons.warning_amber_rounded
                                            : (task.isRecurring
                                                  ? Icons.repeat
                                                  : Icons.task_alt),
                                        size: 48,
                                        color: task.status == TaskStatus.late
                                            ? Colors.red
                                            : Colors.blue,
                                      ),
                                    ),
                              )
                            : Center(
                                child: Icon(
                                  task.status == TaskStatus.late
                                      ? Icons.warning_amber_rounded
                                      : (task.isRecurring
                                            ? Icons.repeat
                                            : Icons.task_alt),
                                  size: 48,
                                  color: task.status == TaskStatus.late
                                      ? Colors.red
                                      : Colors.blue,
                                ),
                              ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${task.points} KP',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (task.status == TaskStatus.completed)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    onPressed: () =>
                                        _approveTask(context, ref, task),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                if (task.status == TaskStatus.late)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      'LATE',
                                      style: GoogleFonts.kanit(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () =>
                                      _showEditTaskDialog(context, ref, task),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _confirmDelete(context, ref, task),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditTaskDialog(
    BuildContext context,
    WidgetRef ref,
    TaskEntity task,
  ) {
    showDialog(
      context: context,
      builder: (_) => AddTaskDialog(
        isEditing: true,
        initialTitle: task.title,
        initialDescription: task.description,
        initialPoints: task.points,
        initialIsRecurring: task.isRecurring,
        initialStartTime: task.startTime,
        initialEndTime: task.endTime,
        initialImageUrl: task.imageUrl,
        initialReminderMinutes: task.reminderMinutes,
        onSave:
            (
              title,
              description,
              points,
              isRecurring,
              startTime,
              endTime,
              imageUrl,
              reminderMinutes,
            ) async {
              await ref
                  .read(taskControllerProvider.notifier)
                  .updateTask(
                    taskId: task.id,
                    title: title,
                    description: description,
                    points: points,
                    isRecurring: isRecurring,
                    parentId: parentId,
                    childId: childId,
                    status: task.status,
                    startTime: startTime,
                    endTime: endTime,
                    imageUrl: imageUrl,
                    reminderMinutes: reminderMinutes,
                  );
            },
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AddTaskDialog(
        onSave:
            (
              title,
              description,
              points,
              isRecurring,
              startTime,
              endTime,
              imageUrl,
              reminderMinutes,
            ) async {
              await ref
                  .read(taskControllerProvider.notifier)
                  .createTask(
                    title: title,
                    description: description,
                    points: points,
                    isRecurring: isRecurring,
                    parentId: parentId,
                    childId: childId,
                    startTime: startTime,
                    endTime: endTime,
                    imageUrl: imageUrl,
                    reminderMinutes: reminderMinutes,
                  );
            },
      ),
    );
  }

  void _approveTask(BuildContext context, WidgetRef ref, TaskEntity task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Mission?'),
        content: Text('Approve "${task.title}" and award ${task.points} KP?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(taskControllerProvider.notifier)
                  .approveTask(
                    parentId: parentId,
                    childId: childId,
                    taskId: task.id,
                    points: task.points,
                  );
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, TaskEntity task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Mission?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(taskControllerProvider.notifier)
                  .deleteTask(parentId, childId, task.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

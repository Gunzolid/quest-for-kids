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
    final tasksAsync =
        ref.watch(tasksStreamProvider((parentId: parentId, childId: childId)));

    return Scaffold(
      appBar: AppBar(
        title: Text('Missions for $childName'),
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No active missions.',
                    style: GoogleFonts.kanit(
                        fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const Text('Assign a mission to start the adventure!'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(
                      task.isRecurring ? Icons.repeat : Icons.task_alt,
                      color: Colors.blue,
                    ),
                  ),
                  title: Text(task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: _buildSubtitle(task),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (task.status == TaskStatus.completed)
                        IconButton(
                          icon: const Icon(Icons.check_circle,
                              color: Colors.green),
                          onPressed: () => _approveTask(context, ref, task),
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _showEditTaskDialog(context, ref, task),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmDelete(context, ref, task),
                      ),
                    ],
                  ),
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
      BuildContext context, WidgetRef ref, TaskEntity task) {
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
        onSave: (title, description, points, isRecurring, startTime,
            endTime) async {
          await ref.read(taskControllerProvider.notifier).updateTask(
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
              );
        },
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AddTaskDialog(
        onSave: (title, description, points, isRecurring, startTime,
            endTime) async {
          await ref.read(taskControllerProvider.notifier).createTask(
                title: title,
                description: description,
                points: points,
                isRecurring: isRecurring,
                parentId: parentId,
                childId: childId,
                startTime: startTime,
                endTime: endTime,
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
              await ref.read(taskControllerProvider.notifier).approveTask(
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
              ref.read(taskControllerProvider.notifier).deleteTask(
                    parentId,
                    childId,
                    task.id,
                  );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(TaskEntity task) {
    String text = '${task.description}\n${task.points} KP';
    if (task.startTime != null) {
      String timeStr = _formatDate(task.startTime!);
      if (task.endTime != null) {
        timeStr += ' - ${_formatTime(task.endTime!)}';
      }
      text += '\n$timeStr';
    }
    return Text(text);
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

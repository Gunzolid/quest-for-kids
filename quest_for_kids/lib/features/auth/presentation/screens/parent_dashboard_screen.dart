import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_providers.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current user (Parent)
    final currentUserAsync = ref.watch(authStateChangesProvider);

    return currentUserAsync.when(
      data: (user) {
        if (user == null) {
          // Should normally redirect to login, but for safety:
          return const Scaffold(body: Center(child: Text('Not authenticated')));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Parent Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.card_giftcard),
                tooltip: 'Manage Rewards',
                onPressed: () => context.push('/manage-rewards/${user.id}'),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  ref.read(authControllerProvider.notifier).signOut();
                  context.go('/login');
                },
              ),
            ],
          ),
          body: _buildChildList(context, ref, user.id),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddChildDialog(context, ref, user.id),
            child: const Icon(Icons.person_add),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildChildList(BuildContext context, WidgetRef ref, String parentId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(parentId)
          .collection('children')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.child_care, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'No children added yet.',
                  style: GoogleFonts.kanit(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Text('Tap + to add your first child.'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final childId = docs[index].id;
            final name = data['name'] as String? ?? 'Unknown';
            final points = data['current_points'] as int? ?? 0;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                onTap: () {
                  context.push(
                    '/manage-tasks/$childId',
                    extra: {
                      'parentId': parentId,
                      'childName': name,
                    },
                  );
                },
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KP Points: $points'),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'ID: $childId',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 14),
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: childId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('ID copied to clipboard')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditChildDialog(
                        context,
                        ref,
                        parentId,
                        childId,
                        name,
                        // Pass current passcode if available or handle logic
                        // For MVP we might not show current passcode for security?
                        // But let's assume we want to overwrite it.
                        // Or we can pass null to keep existing.
                      );
                    } else if (value == 'delete') {
                      _confirmDeleteChild(
                          context, ref, parentId, childId, name);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Edit Profile'),
                      ]),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Profile'),
                      ]),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddChildDialog(
      BuildContext context, WidgetRef ref, String parentId) {
    // Reusing logic for clean code?
    // Let's keep separate for now as "Add" requires fields, "Edit" might be optional field updates.
    // For simplicity, let's copy/paste structure but adapt for Add.
    final nameController = TextEditingController();
    final passcodeController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Child Profile'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Child Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passcodeController,
                decoration: const InputDecoration(
                  labelText: 'Passcode (6 digits)',
                  helperText: 'Numbers only',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.length != 6) {
                    return 'Must be exactly 6 digits';
                  }
                  if (int.tryParse(v) == null) {
                    return 'Numbers only';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext);
                await ref.read(authControllerProvider.notifier).addChildProfile(
                      nameController.text.trim(),
                      passcodeController.text.trim(),
                      parentId,
                    );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditChildDialog(
    BuildContext context,
    WidgetRef ref,
    String parentId,
    String childId,
    String currentName,
  ) {
    final nameController = TextEditingController(text: currentName);
    final passcodeController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Child Profile'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Child Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passcodeController,
                decoration: const InputDecoration(
                  labelText: 'New Passcode (Optional)',
                  helperText: 'Leave empty to keep existing',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return null; // Optional
                  if (v.length != 6) {
                    return 'Must be exactly 6 digits';
                  }
                  if (int.tryParse(v) == null) {
                    return 'Numbers only';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext);
                final newName = nameController.text.trim();
                final newPass = passcodeController.text.trim();

                await ref
                    .read(authControllerProvider.notifier)
                    .updateChildProfile(
                      parentId,
                      childId,
                      name: newName,
                      passcode: newPass.isEmpty ? null : newPass,
                    );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteChild(
    BuildContext context,
    WidgetRef ref,
    String parentId,
    String childId,
    String childName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Child Profile?'),
        content: Text(
            'Are you sure you want to delete "$childName"?\nThis cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(authControllerProvider.notifier)
                  .deleteChildProfile(parentId, childId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

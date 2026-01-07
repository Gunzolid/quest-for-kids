import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../rewards/domain/entities/reward_entity.dart';
import '../../rewards/presentation/providers/reward_providers.dart';
import '../domain/entities/task_entity.dart';
import 'providers/task_providers.dart';

class ChildDashboardScreen extends ConsumerStatefulWidget {
  const ChildDashboardScreen({super.key});

  @override
  ConsumerState<ChildDashboardScreen> createState() =>
      _ChildDashboardScreenState();
}

class _ChildDashboardScreenState extends ConsumerState<ChildDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Initial auth state for IDs
    final authState = ref.watch(authControllerProvider);
    final initialUser = authState.value;

    if (initialUser == null || initialUser.parentId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Session expired or not found'),
              ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Back to Login'))
            ],
          ),
        ),
      );
    }

    // Connect to real-time stream
    final childAsync = ref.watch(childStreamProvider(
        (parentId: initialUser.parentId!, childId: initialUser.id)));

    return childAsync.when(
      data: (user) {
        return Scaffold(
          body: _buildBody(
              user.name, user.currentPoints ?? 0, user.parentId!, user.id),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              selectedItemColor: Colors.orange,
              unselectedItemColor: Colors.grey,
              selectedLabelStyle:
                  GoogleFonts.kanit(fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.kanit(),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.list_alt),
                  label: 'Missions',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.star),
                  label: 'Rewards',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'History',
                ),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(
        body: Center(child: Text('Error loading profile: $e')),
      ),
    );
  }

  Widget _buildBody(String name, int points, String parentId, String childId) {
    switch (_selectedIndex) {
      case 0:
        return _buildMissionsTab(name, points);
      case 1:
        return _buildRewardsTab(points, parentId, childId);
      case 2:
        return _buildHistoryTab(parentId, childId);
      default:
        return const SizedBox();
    }
  }

  Widget _buildMissionsTab(String name, int points) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello,', style: GoogleFonts.kanit(fontSize: 18)),
                        Text(
                          name,
                          style: GoogleFonts.kanit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.orange.withOpacity(0.2),
                                  blurRadius: 8)
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.stars, color: Colors.orange),
                              const SizedBox(width: 8),
                              Text(
                                '$points KP',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            ref.read(authControllerProvider.notifier).signOut();
                          },
                          icon: const Icon(Icons.logout, color: Colors.red),
                          tooltip: 'Logout',
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Today\'s Missions',
              style:
                  GoogleFonts.kanit(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

// ... (inside _buildMissionsTab)

          // Mission List (Real)
          Expanded(
            child: Consumer(builder: (context, ref, child) {
              // We need parentId and childId.
              // We know 'user' (from param or provider) has this info.
              // But 'user' passed to this method is just name and points.
              // We need the full user object or IDs.
              // Let's rely on the parent 'user' object from build method being available if we change signature
              // or just re-access provider?
              // Better: pass UserEntity to _buildMissionsTab.
              final authState = ref.watch(authControllerProvider);
              final user = authState.value!;

              if (user.parentId == null)
                return const Center(child: Text('Error: No Parent ID'));

              final tasksAsync = ref.watch(tasksStreamProvider(
                  (parentId: user.parentId!, childId: user.id)));

              return tasksAsync.when(
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return Center(
                        child: Text('No missions for today!',
                            style: GoogleFonts.kanit(
                                fontSize: 18, color: Colors.grey)));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      // Assign color based on index or hash for variety
                      final color = [
                        Colors.blue,
                        Colors.purple,
                        Colors.green,
                        Colors.orange
                      ][index % 4];
                      return _buildMissionCard(task, color);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(TaskEntity task, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.task_alt, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                      style: GoogleFonts.kanit(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(task.description,
                      style: GoogleFonts.kanit(color: Colors.grey.shade600)),
                  if (task.startTime != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatTaskTime(task),
                        style: GoogleFonts.kanit(
                            fontSize: 12,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    '+${task.points} KP',
                    style: GoogleFonts.kanit(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: task.status == TaskStatus.pending
                      ? () async {
                          final authState =
                              ref.read(authControllerProvider).value;
                          if (authState != null && authState.parentId != null) {
                            await ref
                                .read(taskControllerProvider.notifier)
                                .markTaskAsCompleted(
                                  parentId: authState.parentId!,
                                  childId: authState.id,
                                  taskId: task.id,
                                  points: task.points,
                                );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: task.status == TaskStatus.pending
                        ? color
                        : (task.status == TaskStatus.approved
                            ? Colors.green
                            : Colors.grey),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    task.status == TaskStatus.approved
                        ? 'Completed'
                        : (task.status == TaskStatus.completed
                            ? 'Check...'
                            : 'Done'),
                    style: GoogleFonts.kanit(fontSize: 12),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  String _formatTaskTime(TaskEntity task) {
    if (task.startTime == null) return '';
    final start =
        '${task.startTime!.hour.toString().padLeft(2, '0')}:${task.startTime!.minute.toString().padLeft(2, '0')}';
    if (task.endTime != null) {
      final end =
          '${task.endTime!.hour.toString().padLeft(2, '0')}:${task.endTime!.minute.toString().padLeft(2, '0')}';
      return 'Time: $start - $end';
    }
    return 'Start: $start';
  }

  Widget _buildRewardsTab(int currentPoints, String parentId, String childId) {
    final rewardsAsync = ref.watch(rewardsStreamProvider(parentId));

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.pink.shade100,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rewards',
                style: GoogleFonts.kanit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade800),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.pink.withOpacity(0.2), blurRadius: 8)
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      '$currentPoints KP',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Rewards Grid
        Expanded(
          child: rewardsAsync.when(
            data: (rewards) {
              if (rewards.isEmpty) {
                return Center(
                    child: Text('No rewards available yet!',
                        style: GoogleFonts.kanit(
                            fontSize: 18, color: Colors.grey)));
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: rewards.length,
                itemBuilder: (context, index) {
                  final reward = rewards[index];
                  final canAfford = currentPoints >= reward.cost;
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      onTap: () {
                        if (canAfford) {
                          _confirmRedeem(context, ref, reward, childId,
                              parentId, currentPoints);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Not enough points yet!')),
                          );
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.card_giftcard,
                              size: 48,
                              color: canAfford
                                  ? Colors.pink
                                  : Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            reward.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: canAfford
                                  ? Colors.pink.shade50
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${reward.cost} KP',
                              style: TextStyle(
                                  color: canAfford
                                      ? Colors.pink.shade800
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold),
                            ),
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
        ),
      ],
    );
  }

  void _confirmRedeem(BuildContext context, WidgetRef ref, RewardEntity reward,
      String childId, String parentId, int currentPoints) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redeem Reward?'),
        content: Text(
            'Spend ${reward.cost} KP for "${reward.name}"?\nYou will have ${currentPoints - reward.cost} KP left.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(rewardControllerProvider.notifier).redeemReward(
                    parentId: parentId,
                    childId: childId,
                    rewardId: reward.id,
                    cost: reward.cost,
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Redeemed "${reward.name}"! Enjoy!')),
                );
              }
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(String parentId, String childId) {
    final tasksAsync =
        ref.watch(tasksStreamProvider((parentId: parentId, childId: childId)));

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Mission History',
              style: GoogleFonts.kanit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
          ),
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                // Show approved (history) tasks
                final completedTasks = tasks
                    .where((t) => t.status == TaskStatus.approved)
                    .toList();

                if (completedTasks.isEmpty) {
                  return Center(
                      child: Text('No completed missions yet.',
                          style: GoogleFonts.kanit(color: Colors.grey)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: completedTasks.length,
                  itemBuilder: (context, index) {
                    final task = completedTasks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      color: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200)),
                      child: ListTile(
                        leading: const Icon(Icons.check_circle,
                            color: Colors.green, size: 32),
                        title: Text(
                          task.title,
                          style: GoogleFonts.kanit(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey),
                        ),
                        subtitle: Text(
                          '+${task.points} KP',
                          style: GoogleFonts.kanit(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

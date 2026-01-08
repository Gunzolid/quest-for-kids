import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/reward_entity.dart';
import '../providers/reward_providers.dart';
import '../widgets/add_reward_dialog.dart';

class ManageRewardsScreen extends ConsumerWidget {
  final String parentId;

  const ManageRewardsScreen({super.key, required this.parentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardsAsync = ref.watch(rewardsStreamProvider(parentId));

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Rewards')),
      body: rewardsAsync.when(
        data: (rewards) {
          if (rewards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_giftcard,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No rewards created.',
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Text('Add rewards to motivate your kids!'),
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
            itemCount: rewards.length,
            itemBuilder: (context, index) {
              final reward = rewards[index];
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
                        color: Colors.pink.shade50,
                        child:
                            reward.imageUrl != null &&
                                reward.imageUrl!.isNotEmpty
                            ? Image.network(
                                reward.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(
                                      child: Icon(
                                        Icons.star,
                                        size: 48,
                                        color: Colors.pink,
                                      ),
                                    ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.star,
                                  size: 48,
                                  color: Colors.pink,
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
                              reward.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${reward.cost} KP',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _showEditRewardDialog(
                                    context,
                                    ref,
                                    reward,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _confirmDelete(context, ref, reward),
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
        onPressed: () => _showAddRewardDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddRewardDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AddRewardDialog(
        onSave: (name, cost, imageUrl) async {
          await ref
              .read(rewardControllerProvider.notifier)
              .createReward(
                name: name,
                cost: cost,
                imageUrl: imageUrl,
                parentId: parentId,
              );
        },
      ),
    );
  }

  void _showEditRewardDialog(
    BuildContext context,
    WidgetRef ref,
    RewardEntity reward,
  ) {
    showDialog(
      context: context,
      builder: (_) => AddRewardDialog(
        isEditing: true,
        initialName: reward.name,
        initialCost: reward.cost,
        initialImageUrl: reward.imageUrl,
        onSave: (name, cost, imageUrl) async {
          await ref
              .read(rewardControllerProvider.notifier)
              .updateReward(
                id: reward.id,
                name: name,
                cost: cost,
                imageUrl: imageUrl,
                parentId: parentId,
              );
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    RewardEntity reward,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reward?'),
        content: Text('Are you sure you want to delete "${reward.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(rewardControllerProvider.notifier)
                  .deleteReward(parentId, reward.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

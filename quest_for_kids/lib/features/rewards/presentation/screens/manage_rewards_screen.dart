import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/reward_entity.dart';
import '../providers/reward_providers.dart';
import '../widgets/add_reward_dialog.dart';

class ManageRewardsScreen extends ConsumerWidget {
  final String parentId;

  const ManageRewardsScreen({
    super.key,
    required this.parentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardsAsync = ref.watch(rewardsStreamProvider(parentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Rewards'),
      ),
      body: rewardsAsync.when(
        data: (rewards) {
          if (rewards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No rewards created.',
                    style: GoogleFonts.kanit(
                        fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const Text('Add rewards to motivate your kids!'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rewards.length,
            itemBuilder: (context, index) {
              final reward = rewards[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.pink.shade50,
                    child: const Icon(Icons.star, color: Colors.pink),
                  ),
                  title: Text(reward.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${reward.cost} KP'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _showEditRewardDialog(context, ref, reward),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmDelete(context, ref, reward),
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
          await ref.read(rewardControllerProvider.notifier).createReward(
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
      BuildContext context, WidgetRef ref, RewardEntity reward) {
    showDialog(
      context: context,
      builder: (_) => AddRewardDialog(
        isEditing: true,
        initialName: reward.name,
        initialCost: reward.cost,
        initialImageUrl: reward.imageUrl,
        onSave: (name, cost, imageUrl) async {
          await ref.read(rewardControllerProvider.notifier).updateReward(
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
      BuildContext context, WidgetRef ref, RewardEntity reward) {
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
              ref.read(rewardControllerProvider.notifier).deleteReward(
                    parentId,
                    reward.id,
                  );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

import '../entities/reward_entity.dart';

abstract class RewardRepository {
  Stream<List<RewardEntity>> getRewards(String parentId);
  Future<void> createReward(RewardEntity reward);
  Future<void> updateReward(RewardEntity reward);
  Future<void> deleteReward(String parentId, String rewardId);
  Future<void> redeemReward(
      String parentId, String childId, String rewardId, int cost);
}

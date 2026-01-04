import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/auth_failures.dart';
import '../models/reward_model.dart';
import '../../domain/entities/reward_entity.dart';
import '../../domain/repositories/reward_repository.dart';

class RewardRepositoryImpl implements RewardRepository {
  final FirebaseFirestore _firestore;

  RewardRepositoryImpl(this._firestore);

  @override
  Stream<List<RewardEntity>> getRewards(String parentId) {
    return _firestore
        .collection('users')
        .doc(parentId)
        .collection('rewards')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RewardModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<void> createReward(RewardEntity reward) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(reward.parentId)
          .collection('rewards')
          .doc();

      final model = RewardModel(
        id: docRef.id,
        name: reward.name,
        cost: reward.cost,
        imageUrl: reward.imageUrl,
        parentId: reward.parentId,
      );

      await docRef.set(model.toJson()..remove('id'));
    } catch (e) {
      throw AuthFailure('Failed to create reward: $e');
    }
  }

  @override
  Future<void> updateReward(RewardEntity reward) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(reward.parentId)
          .collection('rewards')
          .doc(reward.id);

      final model = RewardModel(
        id: reward.id,
        name: reward.name,
        cost: reward.cost,
        imageUrl: reward.imageUrl,
        parentId: reward.parentId,
      );

      await docRef.update(model.toJson()..remove('id'));
    } catch (e) {
      throw AuthFailure('Failed to update reward: $e');
    }
  }

  @override
  Future<void> deleteReward(String parentId, String rewardId) async {
    try {
      await _firestore
          .collection('users')
          .doc(parentId)
          .collection('rewards')
          .doc(rewardId)
          .delete();
    } catch (e) {
      throw AuthFailure('Failed to delete reward: $e');
    }
  }

  @override
  Future<void> redeemReward(
      String parentId, String childId, String rewardId, int cost) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // 1. Get Child Data
        final childRef = _firestore
            .collection('users')
            .doc(parentId)
            .collection('children')
            .doc(childId);

        final childSnapshot = await transaction.get(childRef);
        if (!childSnapshot.exists) throw Exception('Child not found');

        final currentPoints =
            childSnapshot.data()?['currentPoints'] as int? ?? 0;
        if (currentPoints < cost) {
          throw Exception('Insufficient points');
        }

        // 2. Deduct Points
        transaction.update(childRef, {'currentPoints': currentPoints - cost});

        // 3. Record Redemption (Optional: Add to 'redemptions' collection)
        // For now, we skip history log to keep it simple, or maybe we log it?
        // Let's create a 'redemptions' subcollection under child for history.
        final redemptionRef = childRef.collection('redemptions').doc();
        transaction.set(redemptionRef, {
          'rewardId': rewardId,
          'cost': cost,
          'date': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw AuthFailure('Redemption failed: $e');
    }
  }
}

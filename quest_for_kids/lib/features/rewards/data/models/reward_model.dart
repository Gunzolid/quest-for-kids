import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/reward_entity.dart';

part 'reward_model.g.dart';

@JsonSerializable()
class RewardModel extends RewardEntity {
  const RewardModel({
    required super.id,
    required super.name,
    required super.cost,
    super.imageUrl,
    required super.parentId,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) =>
      _$RewardModelFromJson(json);

  Map<String, dynamic> toJson() => _$RewardModelToJson(this);

  factory RewardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RewardModel(
      id: doc.id,
      name: data['name'] ?? '',
      cost: data['cost'] ?? 0,
      imageUrl: data['imageUrl'],
      parentId: data['parentId'] ?? '',
    );
  }
}

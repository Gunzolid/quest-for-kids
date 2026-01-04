import 'package:equatable/equatable.dart';

class RewardEntity extends Equatable {
  final String id;
  final String name;
  final int cost;
  final String? imageUrl;
  final String parentId;

  const RewardEntity({
    required this.id,
    required this.name,
    required this.cost,
    this.imageUrl,
    required this.parentId,
  });

  @override
  List<Object?> get props => [id, name, cost, imageUrl, parentId];
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RewardModel _$RewardModelFromJson(Map<String, dynamic> json) => RewardModel(
      id: json['id'] as String,
      name: json['name'] as String,
      cost: (json['cost'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
      parentId: json['parentId'] as String,
    );

Map<String, dynamic> _$RewardModelToJson(RewardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'cost': instance.cost,
      'imageUrl': instance.imageUrl,
      'parentId': instance.parentId,
    };

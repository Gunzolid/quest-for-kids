// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      email: json['email'] as String?,
      currentPoints: (json['current_points'] as num?)?.toInt(),
      passcode: json['passcode'] as String?,
      parentId: json['parent_id'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'role': _$UserRoleEnumMap[instance.role]!,
      'email': instance.email,
      'current_points': instance.currentPoints,
      'passcode': instance.passcode,
      'parent_id': instance.parentId,
    };

const _$UserRoleEnumMap = {
  UserRole.parent: 'parent',
  UserRole.child: 'child',
};

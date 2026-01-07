import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel implements UserEntity {
  const UserModel._();

  @override
  List<Object?> get props => [
        id,
        name,
        avatarUrl,
        role,
        email,
        currentPoints,
        passcode,
        parentId,
      ];

  @override
  bool? get stringify => true;

  const factory UserModel({
    required String id,
    required String name,
    String? avatarUrl,
    required UserRole role,
    String? email,
    @JsonKey(name: 'currentPoints') int? currentPoints,
    String? passcode,
    @JsonKey(name: 'parent_id') String? parentId,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }
}

import 'package:equatable/equatable.dart';

enum UserRole { parent, child }

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final UserRole role;

  // Parent specific
  final String? email;

  // Child specific
  final int? currentPoints;
  final String? passcode; // PIN for child login
  final String? parentId; // Link to parent

  const UserEntity({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.role,
    this.email,
    this.currentPoints,
    this.passcode,
    this.parentId,
  });

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
}

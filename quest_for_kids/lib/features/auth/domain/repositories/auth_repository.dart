import 'package:quest_for_kids/core/errors/auth_failures.dart';
import '../entities/user_entity.dart';

/// Interface for Authentication Repository.
///
/// Note: Methods return [Future<UserEntity>] and throw [AuthFailure] on error
/// to support standard try-catch handling as requested.
abstract class AuthRepository {
  /// Login for Parent using email and password.
  Future<UserEntity> loginParent(String email, String password);

  /// Login a child using their unique ID, Parent ID, and passcode.
  Future<UserEntity> loginChild(
      String childId, String parentId, String passcode);

  /// Register a new Parent account.
  Future<UserEntity> registerParent(String email, String password, String name);

  /// Add a child profile to the current parent account.
  Future<UserEntity> addChildProfile(
      String name, String passcode, String parentId);

  /// Sign out the current user.
  Future<void> signOut();

  /// Get the current authenticated user state.
  Stream<UserEntity?> getCurrentUser();

  /// Find parent user by email (for Child Login flow).
  Future<UserEntity?> getUsersByEmail(String email);

  /// Get all children for a specific parent.
  Future<List<UserEntity>> getChildrenOfParent(String parentUid);

  /// Update a child profile.
  Future<void> updateChildProfile(String parentId, String childId,
      {String? name, String? passcode});

  /// Delete a child profile.
  Future<void> deleteChildProfile(String parentId, String childId);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// --- Dependencies ---
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

// --- Repository Provider ---
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

// --- Auth State Stream ---
final authStateChangesProvider = StreamProvider<UserEntity?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.getCurrentUser();
});

// --- Child Stream Provider ---
final childStreamProvider =
    StreamProvider.family<UserEntity, ({String parentId, String childId})>(
        (ref, args) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.streamChildProfile(args.parentId, args.childId);
});

// --- Auth Controller ---
class AuthController extends AsyncNotifier<UserEntity?> {
  @override
  Future<UserEntity?> build() async {
    return null;
  }

  Future<void> loginParent(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref
          .read(authRepositoryProvider)
          .loginParent(email, password);
    });
  }

  Future<void> registerParent(
      String email, String password, String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref
          .read(authRepositoryProvider)
          .registerParent(email, password, name);
    });
  }

  Future<void> addChildProfile(
      String name, String passcode, String parentId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref
          .read(authRepositoryProvider)
          .addChildProfile(name, passcode, parentId);
    });
  }

  Future<void> loginChild(
      String childId, String parentId, String passcode) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref
          .read(authRepositoryProvider)
          .loginChild(childId, parentId, passcode);
    });
  }

  Future<void> updateChildProfile(String parentId, String childId,
      {String? name, String? passcode}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).updateChildProfile(
          parentId, childId,
          name: name, passcode: passcode);
      // Refresh current user or children list?
      // Since children list is a Stream in UI, it should auto-update.
      return null;
    });
  }

  Future<void> deleteChildProfile(String parentId, String childId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .deleteChildProfile(parentId, childId);
      return null;
    });
  }

  Future<void> updateChildPoints(
      String parentId, String childId, int newPoints) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .updateChildPoints(parentId, childId, newPoints);
      return null;
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
      return null;
    });
  }

  Future<UserEntity?> findParentByEmail(String email) async {
    // This doesn't set global state, just returns result
    return ref.read(authRepositoryProvider).getUsersByEmail(email);
  }

  Future<List<UserEntity>> fetchChildren(String parentId) async {
    return ref.read(authRepositoryProvider).getChildrenOfParent(parentId);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserEntity?>(AuthController.new);

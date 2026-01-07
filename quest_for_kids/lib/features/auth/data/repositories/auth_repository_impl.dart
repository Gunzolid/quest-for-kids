import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/auth_failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._firebaseAuth, this._firestore);

  @override
  Future<UserEntity> registerParent(
      String email, String password, String name) async {
    UserCredential? credential;
    try {
      // 1. Create Auth User
      credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      final user = UserModel(
        id: uid,
        name: name,
        email: email,
        role: UserRole.parent,
      );

      // 2. Write to Firestore with specific error handling
      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .set(user.toJson()..remove('id'));
      } catch (firestoreError) {
        // Log the specific error
        print('Firestore Write Failed: $firestoreError');

        // 3. Rollback: Delete the created auth user
        await credential.user?.delete();
        throw AuthFailure('Failed to save user data: $firestoreError');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Registration failed');
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw AuthFailure('Unexpected error: $e');
    }
  }

  @override
  Future<UserEntity> loginParent(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc =
          await _firestore.collection('users').doc(credential.user!.uid).get();

      if (!doc.exists) {
        throw const AuthFailure('User profile not found');
      }

      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Login failed');
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<UserEntity> addChildProfile(
      String name, String passcode, String parentId) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(parentId)
          .collection('children')
          .doc();

      final child = UserModel(
        id: docRef.id,
        name: name,
        passcode: passcode,
        role: UserRole.child,
        parentId: parentId,
        currentPoints: 0,
      );

      await docRef.set(child.toJson()..remove('id'));

      return child;
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<UserEntity> loginChild(
      String childId, String parentId, String passcode) async {
    try {
      // Direct lookup using known parent path - efficient and error-free
      final doc = await _firestore
          .collection('users')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .get();

      if (!doc.exists) {
        throw const AuthFailure('Child profile not found');
      }

      final child = UserModel.fromFirestore(doc);

      print(
          'DEBUG: LoginChild - Input: "$passcode" vs Stored: "${child.passcode}"');

      if (child.passcode != passcode) {
        throw const AuthFailure('Invalid passcode');
      }

      return child;
    } catch (e) {
      print('DEBUG: LoginChild Error: $e');
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserEntity?> getUsersByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return UserModel.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      throw AuthFailure('Error finding family: $e');
    }
  }

  @override
  Future<List<UserEntity>> getChildrenOfParent(String parentUid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(parentUid)
          .collection('children')
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw AuthFailure('Error fetching children: $e');
    }
  }

  @override
  Future<void> updateChildProfile(String parentId, String childId,
      {String? name, String? passcode}) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (passcode != null) updates['passcode'] = passcode;

      if (updates.isEmpty) return;

      await _firestore
          .collection('users')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .update(updates);
    } catch (e) {
      throw AuthFailure('Failed to update child profile: $e');
    }
  }

  @override
  Future<void> deleteChildProfile(String parentId, String childId) async {
    try {
      final childRef = _firestore
          .collection('users')
          .doc(parentId)
          .collection('children')
          .doc(childId);

      // 1. Delete tasks subcollection manually (Client-side cascade)
      final tasksSnapshot = await childRef.collection('tasks').get();
      for (final doc in tasksSnapshot.docs) {
        await doc.reference.delete();
      }

      // 2. Delete the child document
      await childRef.delete();
    } catch (e) {
      throw AuthFailure('Failed to delete child profile: $e');
    }
  }

  @override
  Future<void> updateChildPoints(
      String parentId, String childId, int newPoints) async {
    try {
      await _firestore
          .collection('users')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .update({'currentPoints': newPoints});
    } catch (e) {
      throw AuthFailure('Failed to update points: $e');
    }
  }

  @override
  Stream<UserEntity> streamChildProfile(String parentId, String childId) {
    return _firestore
        .collection('users')
        .doc(parentId)
        .collection('children')
        .doc(childId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        throw AuthFailure('Child not found');
      }
    });
  }

  @override
  Stream<UserEntity?> getCurrentUser() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      // Try to find as parent first
      final parentDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (parentDoc.exists) {
        return UserModel.fromFirestore(parentDoc);
      }
      return null;
    });
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budget/features/user/domain/user_model.dart';
import 'package:budget/features/user/data/user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseAuth _auth;

  FirebaseUserRepository({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return UserModel(
      id: firebaseUser.uid,
      isAnonymous: firebaseUser.isAnonymous,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );
  }

  @override
  Future<UserModel> createAnonymousUser() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Failed to create anonymous user');
      }

      return UserModel(
        id: firebaseUser.uid,
        isAnonymous: true,
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to create anonymous user: $e');
    }
  }
}

final firebaseUserRepositoryProvider = Provider<UserRepository>((ref) {
  return FirebaseUserRepository();
});

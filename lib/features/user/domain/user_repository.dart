import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budget/features/user/domain/user_model.dart';
import 'package:budget/features/user/data/firebase_user_repository.dart';

abstract class UserRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> createAnonymousUser();
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirebaseUserRepository();
});

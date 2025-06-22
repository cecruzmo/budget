import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budget/features/user/domain/user_model.dart';
import 'package:budget/features/user/data/user_repository.dart';

class UserService {
  final UserRepository _repository;

  UserService(this._repository);

  Future<UserModel> initUser() async {
    final currentUser = getCurrentUser();
    if (currentUser == null) return await createAnonymousUser();
    return currentUser;
  }

  Future<UserModel> createAnonymousUser() async =>
      await _repository.createAnonymousUser();

  UserModel? getCurrentUser() => _repository.getCurrentUser();
}

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(userRepositoryProvider));
});

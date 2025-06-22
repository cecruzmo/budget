import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budget/features/user/domain/user_model.dart';
import 'package:budget/features/user/application/user_service.dart';

class UserController extends StateNotifier<AsyncValue<UserModel?>> {
  final UserService _userService;

  UserController(this._userService) : super(const AsyncValue.loading());

  Future<void> initUser() async =>
      state = await AsyncValue.guard(() => _userService.initUser());
}

final userControllerProvider =
    StateNotifierProvider<UserController, AsyncValue<UserModel?>>((ref) {
      return UserController(ref.watch(userServiceProvider));
    });

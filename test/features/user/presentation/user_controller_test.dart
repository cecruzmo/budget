import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:budget/features/user/domain/user_model.dart';
import 'package:budget/features/user/application/user_service.dart';
import 'package:budget/features/user/presentation/user_controller.dart';

class MockUserService extends Mock implements UserService {}

void main() {
  late MockUserService mockUserService;
  late UserController userController;

  setUp(() {
    mockUserService = MockUserService();
    userController = UserController(mockUserService);
  });

  group('UserController', () {
    test('initial state should be loading', () {
      expect(userController.state, const AsyncValue<UserModel?>.loading());
    });

    test('should initialize user successfully', () async {
      // Arrange
      final mockUser = UserModel(id: 'test-id', isAnonymous: true);
      when(() => mockUserService.initUser()).thenAnswer((_) async => mockUser);

      // Act
      await userController.initUser();

      // Assert
      expect(userController.state.value, mockUser);
      verify(() => mockUserService.initUser()).called(1);
    });

    test('should handle initialization error', () async {
      // Arrange
      final error = Exception('Failed to initialize user');
      when(() => mockUserService.initUser()).thenThrow(error);

      // Act
      await userController.initUser();

      // Assert
      expect(userController.state.hasError, true);
      expect(userController.state.error, error);
      verify(() => mockUserService.initUser()).called(1);
    });
  });
}

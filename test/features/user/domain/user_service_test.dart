import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:budget/features/user/domain/user_model.dart';
import 'package:budget/features/user/data/user_repository.dart';
import 'package:budget/features/user/application/user_service.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late UserService userService;
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    userService = UserService(mockRepository);
  });

  group('UserService', () {
    final mockUser = UserModel(id: 'test-id', isAnonymous: true);

    test('initUser returns existing user when available', () async {
      // Arrange
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => mockUser);

      // Act
      final result = await userService.initUser();

      // Assert
      expect(result, equals(mockUser));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNever(() => mockRepository.createAnonymousUser());
    });

    test('initUser creates anonymous user when no user exists', () async {
      // Arrange
      when(() => mockRepository.getCurrentUser()).thenAnswer((_) async => null);
      when(
        () => mockRepository.createAnonymousUser(),
      ).thenAnswer((_) async => mockUser);

      // Act
      final result = await userService.initUser();

      // Assert
      expect(result, equals(mockUser));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verify(() => mockRepository.createAnonymousUser()).called(1);
    });

    test('createAnonymousUser calls repository method', () async {
      // Arrange
      when(
        () => mockRepository.createAnonymousUser(),
      ).thenAnswer((_) async => mockUser);

      // Act
      final result = await userService.createAnonymousUser();

      // Assert
      expect(result, equals(mockUser));
      verify(() => mockRepository.createAnonymousUser()).called(1);
    });

    test('getCurrentUser returns user from repository', () async {
      // Arrange
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => mockUser);

      // Act
      final result = await userService.getCurrentUser();

      // Assert
      expect(result, equals(mockUser));
      verify(() => mockRepository.getCurrentUser()).called(1);
    });

    test('getCurrentUser returns null when no user exists', () async {
      // Arrange
      when(() => mockRepository.getCurrentUser()).thenAnswer((_) async => null);

      // Act
      final result = await userService.getCurrentUser();

      // Assert
      expect(result, isNull);
      verify(() => mockRepository.getCurrentUser()).called(1);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:budget/features/user/domain/user_model.dart';

void main() {
  group('UserModel', () {
    test('should create a user with required parameters', () {
      // Arrange
      const testId = 'test-id';
      const isAnonymous = false;

      // Act
      final user = UserModel(id: testId, isAnonymous: isAnonymous);

      // Assert
      expect(user.id, equals(testId));
      expect(user.isAnonymous, equals(isAnonymous));
      expect(user.createdAt, isA<DateTime>());
    });

    test('should create a user with custom createdAt', () {
      // Arrange
      const testId = 'test-id';
      const isAnonymous = false;
      final customDate = DateTime(2024, 1, 1);

      // Act
      final user = UserModel(
        id: testId,
        isAnonymous: isAnonymous,
        createdAt: customDate,
      );

      // Assert
      expect(user.createdAt, equals(customDate));
    });

    test('should create a copy with modified fields', () {
      // Arrange
      const originalId = 'original-id';
      const newId = 'new-id';
      const isAnonymous = false;
      final originalUser = UserModel(id: originalId, isAnonymous: isAnonymous);

      // Act
      final modifiedUser = originalUser.copyWith(id: newId, isAnonymous: true);

      // Assert
      expect(modifiedUser.id, equals(newId));
      expect(modifiedUser.isAnonymous, equals(true));
      expect(modifiedUser.createdAt, equals(originalUser.createdAt));
    });

    test('should create a copy with unchanged fields', () {
      // Arrange
      const originalId = 'original-id';
      const isAnonymous = false;
      final originalUser = UserModel(id: originalId, isAnonymous: isAnonymous);

      // Act
      final copiedUser = originalUser.copyWith();

      // Assert
      expect(copiedUser.id, equals(originalId));
      expect(copiedUser.isAnonymous, equals(isAnonymous));
      expect(copiedUser.createdAt, equals(originalUser.createdAt));
    });
  });
}

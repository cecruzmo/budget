import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:budget/features/budget/domain/firebase_budget_model.dart';

void main() {
  group('FirebaseBudgetModel', () {
    const testUserId = 'user-123';
    final testDate = DateTime(2024, 1, 15, 10, 30);
    final testTimestamp = Timestamp.fromDate(testDate);

    test('should create a FirebaseBudgetModel with all fields', () {
      // Arrange & Act
      final model = FirebaseBudgetModel(
        id: 'budget-123',
        userId: testUserId,
        createdAt: testDate,
        updatedAt: testDate,
      );

      // Assert
      expect(model.id, equals('budget-123'));
      expect(model.userId, equals(testUserId));
      expect(model.createdAt, equals(testDate));
      expect(model.updatedAt, equals(testDate));
    });

    test('should create a FirebaseBudgetModel with minimal fields', () {
      // Arrange & Act
      final model = FirebaseBudgetModel(userId: testUserId);

      // Assert
      expect(model.id, isNull);
      expect(model.userId, equals(testUserId));
      expect(model.createdAt, isNull);
      expect(model.updatedAt, isNull);
    });

    test('should convert to Map with all fields', () {
      // Arrange
      final model = FirebaseBudgetModel(
        id: 'budget-123',
        userId: testUserId,
        createdAt: testDate,
        updatedAt: testDate,
      );

      // Act
      final map = model.toMap();

      // Assert
      expect(
        map,
        equals({
          'userId': testUserId,
          'createdAt': testTimestamp,
          'updatedAt': testTimestamp,
        }),
      );
    });

    test('should convert to Map with null fields excluded', () {
      // Arrange
      final model = FirebaseBudgetModel(userId: testUserId);

      // Act
      final map = model.toMap();

      // Assert
      expect(map, equals({'userId': testUserId}));
    });

    test('should convert to Map with partial null fields', () {
      // Arrange
      final model = FirebaseBudgetModel(
        userId: testUserId,
        createdAt: testDate,
        // updatedAt is null
      );

      // Act
      final map = model.toMap();

      // Assert
      expect(map, equals({'userId': testUserId, 'createdAt': testTimestamp}));
    });

    test('should convert to Firebase Map with server timestamps', () {
      // Arrange
      final model = FirebaseBudgetModel(userId: testUserId);

      // Act
      final firebaseMap = model.toFirebaseMap();

      // Assert
      expect(firebaseMap['userId'], equals(testUserId));
      expect(firebaseMap['createdAt'], isA<FieldValue>());
      expect(firebaseMap['updatedAt'], isA<FieldValue>());
      expect(firebaseMap['createdAt'], equals(FieldValue.serverTimestamp()));
      expect(firebaseMap['updatedAt'], equals(FieldValue.serverTimestamp()));
    });

    test('should create a copy with new id', () {
      // Arrange
      final original = FirebaseBudgetModel(
        id: 'budget-123',
        userId: testUserId,
        createdAt: testDate,
        updatedAt: testDate,
      );

      // Act
      final copy = original.copyWith(id: 'budget-456');

      // Assert
      expect(copy.id, equals('budget-456'));
      expect(copy.userId, equals(testUserId));
      expect(copy.createdAt, equals(testDate));
      expect(copy.updatedAt, equals(testDate));
      expect(original.id, equals('budget-123')); // Original unchanged
    });

    test('should create a copy with new userId', () {
      // Arrange
      final original = FirebaseBudgetModel(
        id: 'budget-123',
        userId: testUserId,
        createdAt: testDate,
        updatedAt: testDate,
      );

      // Act
      final copy = original.copyWith(userId: 'user-456');

      // Assert
      expect(copy.id, equals('budget-123'));
      expect(copy.userId, equals('user-456'));
      expect(copy.createdAt, equals(testDate));
      expect(copy.updatedAt, equals(testDate));
      expect(original.userId, equals(testUserId)); // Original unchanged
    });

    test('should create a copy with new createdAt', () {
      // Arrange
      final original = FirebaseBudgetModel(
        id: 'budget-123',
        userId: testUserId,
        createdAt: testDate,
        updatedAt: testDate,
      );
      final newDate = DateTime(2024, 2, 20, 15, 45);

      // Act
      final copy = original.copyWith(createdAt: newDate);

      // Assert
      expect(copy.id, equals('budget-123'));
      expect(copy.userId, equals(testUserId));
      expect(copy.createdAt, equals(newDate));
      expect(copy.updatedAt, equals(testDate));
      expect(original.createdAt, equals(testDate)); // Original unchanged
    });

    test('should create a copy with new updatedAt', () {
      // Arrange
      final original = FirebaseBudgetModel(
        id: 'budget-123',
        userId: testUserId,
        createdAt: testDate,
        updatedAt: testDate,
      );
      final newDate = DateTime(2024, 2, 20, 15, 45);

      // Act
      final copy = original.copyWith(updatedAt: newDate);

      // Assert
      expect(copy.id, equals('budget-123'));
      expect(copy.userId, equals(testUserId));
      expect(copy.createdAt, equals(testDate));
      expect(copy.updatedAt, equals(newDate));
      expect(original.updatedAt, equals(testDate)); // Original unchanged
    });

    test('should create a copy with multiple new fields', () {
      // Arrange
      final original = FirebaseBudgetModel(
        id: 'budget-123',
        userId: testUserId,
        createdAt: testDate,
        updatedAt: testDate,
      );
      final newDate = DateTime(2024, 2, 20, 15, 45);

      // Act
      final copy = original.copyWith(
        id: 'budget-456',
        userId: 'user-456',
        createdAt: newDate,
        updatedAt: newDate,
      );

      // Assert
      expect(copy.id, equals('budget-456'));
      expect(copy.userId, equals('user-456'));
      expect(copy.createdAt, equals(newDate));
      expect(copy.updatedAt, equals(newDate));
      expect(original.id, equals('budget-123')); // Original unchanged
      expect(original.userId, equals(testUserId)); // Original unchanged
    });

    test('should create a copy with no changes', () {
      // Arrange
      final original = FirebaseBudgetModel(
        id: 'budget-123',
        userId: testUserId,
        createdAt: testDate,
        updatedAt: testDate,
      );

      // Act
      final copy = original.copyWith();

      // Assert
      expect(copy.id, equals('budget-123'));
      expect(copy.userId, equals(testUserId));
      expect(copy.createdAt, equals(testDate));
      expect(copy.updatedAt, equals(testDate));
      expect(original.id, equals('budget-123')); // Original unchanged
    });

    test('should handle null values in copyWith', () {
      // Arrange
      final original = FirebaseBudgetModel(
        id: 'budget-123',
        userId: testUserId,
        createdAt: testDate,
        updatedAt: testDate,
      );

      // Act
      final copy = original.copyWith(createdAt: null, updatedAt: null);

      // Assert
      expect(copy.id, equals('budget-123'));
      expect(copy.userId, equals(testUserId));
      expect(copy.createdAt, equals(testDate)); // null values are ignored
      expect(copy.updatedAt, equals(testDate)); // null values are ignored
      expect(original.createdAt, equals(testDate)); // Original unchanged
      expect(original.updatedAt, equals(testDate)); // Original unchanged
    });

    test('should handle empty userId', () {
      // Arrange & Act
      final model = FirebaseBudgetModel(userId: '');

      // Assert
      expect(model.userId, equals(''));
      expect(model.toMap()['userId'], equals(''));
    });

    test('should handle special characters in userId', () {
      // Arrange
      const specialUserId = 'user@123!test#456';
      final model = FirebaseBudgetModel(userId: specialUserId);

      // Act
      final map = model.toMap();

      // Assert
      expect(model.userId, equals(specialUserId));
      expect(map['userId'], equals(specialUserId));
    });

    test('should handle very long userId', () {
      // Arrange
      final longUserId = 'a' * 1000;
      final model = FirebaseBudgetModel(userId: longUserId);

      // Act
      final map = model.toMap();

      // Assert
      expect(model.userId, equals(longUserId));
      expect(map['userId'], equals(longUserId));
    });

    test('should handle future dates', () {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(days: 365));
      final model = FirebaseBudgetModel(
        userId: testUserId,
        createdAt: futureDate,
        updatedAt: futureDate,
      );

      // Act
      final map = model.toMap();

      // Assert
      expect(model.createdAt, equals(futureDate));
      expect(model.updatedAt, equals(futureDate));
      expect(map['createdAt'], equals(Timestamp.fromDate(futureDate)));
      expect(map['updatedAt'], equals(Timestamp.fromDate(futureDate)));
    });

    test('should handle past dates', () {
      // Arrange
      final pastDate = DateTime.now().subtract(const Duration(days: 365));
      final model = FirebaseBudgetModel(
        userId: testUserId,
        createdAt: pastDate,
        updatedAt: pastDate,
      );

      // Act
      final map = model.toMap();

      // Assert
      expect(model.createdAt, equals(pastDate));
      expect(model.updatedAt, equals(pastDate));
      expect(map['createdAt'], equals(Timestamp.fromDate(pastDate)));
      expect(map['updatedAt'], equals(Timestamp.fromDate(pastDate)));
    });

    test('should handle same date for createdAt and updatedAt', () {
      // Arrange
      final sameDate = DateTime(2024, 1, 1, 12, 0);
      final model = FirebaseBudgetModel(
        userId: testUserId,
        createdAt: sameDate,
        updatedAt: sameDate,
      );

      // Act
      final map = model.toMap();

      // Assert
      expect(model.createdAt, equals(sameDate));
      expect(model.updatedAt, equals(sameDate));
      expect(map['createdAt'], equals(map['updatedAt']));
    });

    test('should handle different dates for createdAt and updatedAt', () {
      // Arrange
      final createdAt = DateTime(2024, 1, 1, 12, 0);
      final updatedAt = DateTime(2024, 1, 15, 15, 30);
      final model = FirebaseBudgetModel(
        userId: testUserId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      // Act
      final map = model.toMap();

      // Assert
      expect(model.createdAt, equals(createdAt));
      expect(model.updatedAt, equals(updatedAt));
      expect(map['createdAt'], isNot(equals(map['updatedAt'])));
    });
  });
}

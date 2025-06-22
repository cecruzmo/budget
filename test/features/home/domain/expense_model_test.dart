import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:budget/features/home/domain/expense_model.dart';

void main() {
  group('ExpenseModel', () {
    const testId = 'test-expense-id';
    const testName = 'Test Expense';
    const testAmount = 100.50;
    final testDate = DateTime(2024, 1, 15, 10, 30);

    test('should create an expense with required parameters', () {
      // Act
      final expense = ExpenseModel(
        id: testId,
        name: testName,
        amount: testAmount,
        createdAt: testDate,
      );

      // Assert
      expect(expense.id, equals(testId));
      expect(expense.name, equals(testName));
      expect(expense.amount, equals(testAmount));
      expect(expense.createdAt, equals(testDate));
    });

    test('should create a copy with modified fields', () {
      // Arrange
      final originalExpense = ExpenseModel(
        id: testId,
        name: testName,
        amount: testAmount,
        createdAt: testDate,
      );
      const newName = 'Updated Expense';
      const newAmount = 200.75;

      // Act
      final modifiedExpense = originalExpense.copyWith(
        name: newName,
        amount: newAmount,
      );

      // Assert
      expect(modifiedExpense.id, equals(testId));
      expect(modifiedExpense.name, equals(newName));
      expect(modifiedExpense.amount, equals(newAmount));
      expect(modifiedExpense.createdAt, equals(testDate));
    });

    test('should create a copy with unchanged fields', () {
      // Arrange
      final originalExpense = ExpenseModel(
        id: testId,
        name: testName,
        amount: testAmount,
        createdAt: testDate,
      );

      // Act
      final copiedExpense = originalExpense.copyWith();

      // Assert
      expect(copiedExpense.id, equals(testId));
      expect(copiedExpense.name, equals(testName));
      expect(copiedExpense.amount, equals(testAmount));
      expect(copiedExpense.createdAt, equals(testDate));
    });

    test('should create a copy with all fields modified', () {
      // Arrange
      final originalExpense = ExpenseModel(
        id: testId,
        name: testName,
        amount: testAmount,
        createdAt: testDate,
      );
      const newId = 'new-expense-id';
      const newName = 'New Expense';
      const newAmount = 300.25;
      final newDate = DateTime(2024, 2, 20, 15, 45);

      // Act
      final modifiedExpense = originalExpense.copyWith(
        id: newId,
        name: newName,
        amount: newAmount,
        createdAt: newDate,
      );

      // Assert
      expect(modifiedExpense.id, equals(newId));
      expect(modifiedExpense.name, equals(newName));
      expect(modifiedExpense.amount, equals(newAmount));
      expect(modifiedExpense.createdAt, equals(newDate));
    });

    test('should convert to map correctly', () {
      // Arrange
      final expense = ExpenseModel(
        id: testId,
        name: testName,
        amount: testAmount,
        createdAt: testDate,
      );

      // Act
      final map = expense.toMap();

      // Assert
      expect(map['id'], equals(testId));
      expect(map['name'], equals(testName));
      expect(map['amount'], equals(testAmount));
      expect(map['createdAt'], equals(testDate.millisecondsSinceEpoch));
    });

    test('should create from map with valid data', () {
      // Arrange
      final map = {
        'name': testName,
        'amount': testAmount,
        'createdAt': testDate.millisecondsSinceEpoch,
      };

      // Act
      final expense = ExpenseModel.fromMap(map, testId);

      // Assert
      expect(expense.id, equals(testId));
      expect(expense.name, equals(testName));
      expect(expense.amount, equals(testAmount));
      expect(expense.createdAt, equals(testDate));
    });

    test('should create from map with Firebase Timestamp', () {
      // Arrange
      final timestamp = Timestamp.fromDate(testDate);
      final map = {
        'name': testName,
        'amount': testAmount,
        'createdAt': timestamp,
      };

      // Act
      final expense = ExpenseModel.fromMap(map, testId);

      // Assert
      expect(expense.id, equals(testId));
      expect(expense.name, equals(testName));
      expect(expense.amount, equals(testAmount));
      expect(expense.createdAt, equals(testDate));
    });

    test('should throw exception from map with null values', () {
      // Arrange
      final map = <String, dynamic>{};

      // Act & Assert
      expect(
        () => ExpenseModel.fromMap(map, testId),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should create from map with int amount', () {
      // Arrange
      final map = {
        'name': testName,
        'amount': 100, // int instead of double
        'createdAt': testDate.millisecondsSinceEpoch,
      };

      // Act
      final expense = ExpenseModel.fromMap(map, testId);

      // Assert
      expect(expense.amount, equals(100.0));
    });

    test('should handle round-trip conversion (toMap -> fromMap)', () {
      // Arrange
      final originalExpense = ExpenseModel(
        id: testId,
        name: testName,
        amount: testAmount,
        createdAt: testDate,
      );

      // Act
      final map = originalExpense.toMap();
      final reconstructedExpense = ExpenseModel.fromMap(map, testId);

      // Assert
      expect(reconstructedExpense.id, equals(originalExpense.id));
      expect(reconstructedExpense.name, equals(originalExpense.name));
      expect(reconstructedExpense.amount, equals(originalExpense.amount));
      expect(reconstructedExpense.createdAt, equals(originalExpense.createdAt));
    });

    test('should handle zero amount', () {
      // Arrange
      const zeroAmount = 0.0;

      // Act
      final expense = ExpenseModel(
        id: testId,
        name: testName,
        amount: zeroAmount,
        createdAt: testDate,
      );

      // Assert
      expect(expense.amount, equals(0.0));
    });

    test('should handle negative amount', () {
      // Arrange
      const negativeAmount = -50.25;

      // Act
      final expense = ExpenseModel(
        id: testId,
        name: testName,
        amount: negativeAmount,
        createdAt: testDate,
      );

      // Assert
      expect(expense.amount, equals(-50.25));
    });

    test('should handle empty name', () {
      // Arrange
      const emptyName = '';

      // Act
      final expense = ExpenseModel(
        id: testId,
        name: emptyName,
        amount: testAmount,
        createdAt: testDate,
      );

      // Assert
      expect(expense.name, equals(''));
    });

    test('should handle special characters in name', () {
      // Arrange
      final specialName = 'Expense with special chars: @#\$%^&*()';

      // Act
      final expense = ExpenseModel(
        id: testId,
        name: specialName,
        amount: testAmount,
        createdAt: testDate,
      );

      // Assert
      expect(expense.name, equals(specialName));
    });
  });
}

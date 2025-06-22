import 'package:flutter_test/flutter_test.dart';

import 'package:budget/features/budget/domain/budget_model.dart';
import 'package:budget/features/budget/domain/expense_model.dart';

void main() {
  group('BudgetModel', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    final testExpense1 = ExpenseModel(
      id: 'expense-1',
      name: 'Groceries',
      amount: 50.25,
      createdAt: testDate,
    );

    final testExpense2 = ExpenseModel(
      id: 'expense-2',
      name: 'Gas',
      amount: 35.75,
      createdAt: testDate,
    );

    final testExpense3 = ExpenseModel(
      id: 'expense-3',
      name: 'Dinner',
      amount: 25.50,
      createdAt: testDate,
    );

    test('should create a budget with expenses and calculate total', () {
      // Arrange
      final expenses = [testExpense1, testExpense2, testExpense3];
      const expectedTotal = 50.25 + 35.75 + 25.50; // 111.50

      // Act
      final budget = BudgetModel(expenses: expenses);

      // Assert
      expect(budget.expenses, equals(expenses));
      expect(budget.totalExpense, equals(expectedTotal));
    });

    test('should create a budget with empty expenses list', () {
      // Act
      final budget = BudgetModel(expenses: []);

      // Assert
      expect(budget.expenses, isEmpty);
      expect(budget.totalExpense, equals(0.0));
    });

    test('should create a budget with single expense', () {
      // Arrange
      final expenses = [testExpense1];
      const expectedTotal = 50.25;

      // Act
      final budget = BudgetModel(expenses: expenses);

      // Assert
      expect(budget.expenses, equals(expenses));
      expect(budget.totalExpense, equals(expectedTotal));
    });

    test('should create a budget with zero amount expenses', () {
      // Arrange
      final zeroExpense = ExpenseModel(
        id: 'zero-expense',
        name: 'Free Item',
        amount: 0.0,
        createdAt: testDate,
      );
      final expenses = [zeroExpense, testExpense1];

      // Act
      final budget = BudgetModel(expenses: expenses);

      // Assert
      expect(budget.expenses, equals(expenses));
      expect(budget.totalExpense, equals(50.25));
    });

    test('should create a budget with negative amount expenses', () {
      // Arrange
      final negativeExpense = ExpenseModel(
        id: 'negative-expense',
        name: 'Refund',
        amount: -20.0,
        createdAt: testDate,
      );
      final expenses = [testExpense1, negativeExpense];
      const expectedTotal = 50.25 + (-20.0); // 30.25

      // Act
      final budget = BudgetModel(expenses: expenses);

      // Assert
      expect(budget.expenses, equals(expenses));
      expect(budget.totalExpense, equals(expectedTotal));
    });

    test('should create a copy with new expenses', () {
      // Arrange
      final originalBudget = BudgetModel(expenses: [testExpense1]);
      final newExpenses = [testExpense2, testExpense3];

      // Act
      final copiedBudget = originalBudget.copyWith(expenses: newExpenses);

      // Assert
      expect(copiedBudget.expenses, equals(newExpenses));
      expect(copiedBudget.totalExpense, equals(35.75 + 25.50)); // 61.25
      expect(
        originalBudget.expenses,
        equals([testExpense1]),
      ); // Original unchanged
      expect(originalBudget.totalExpense, equals(50.25)); // Original unchanged
    });

    test('should create a copy with unchanged expenses', () {
      // Arrange
      final originalExpenses = [testExpense1, testExpense2];
      final originalBudget = BudgetModel(expenses: originalExpenses);

      // Act
      final copiedBudget = originalBudget.copyWith();

      // Assert
      expect(copiedBudget.expenses, equals(originalExpenses));
      expect(copiedBudget.totalExpense, equals(50.25 + 35.75)); // 86.0
    });

    test('should create a copy with empty expenses list', () {
      // Arrange
      final originalBudget = BudgetModel(
        expenses: [testExpense1, testExpense2],
      );

      // Act
      final copiedBudget = originalBudget.copyWith(expenses: []);

      // Assert
      expect(copiedBudget.expenses, isEmpty);
      expect(copiedBudget.totalExpense, equals(0.0));
    });

    test('should handle large amounts correctly', () {
      // Arrange
      final largeExpense = ExpenseModel(
        id: 'large-expense',
        name: 'Car Purchase',
        amount: 25000.99,
        createdAt: testDate,
      );
      final expenses = [largeExpense, testExpense1];

      // Act
      final budget = BudgetModel(expenses: expenses);

      // Assert
      expect(budget.totalExpense, equals(25000.99 + 50.25)); // 25051.24
    });

    test('should handle decimal precision correctly', () {
      // Arrange
      final preciseExpense1 = ExpenseModel(
        id: 'precise-1',
        name: 'Precise 1',
        amount: 0.01,
        createdAt: testDate,
      );
      final preciseExpense2 = ExpenseModel(
        id: 'precise-2',
        name: 'Precise 2',
        amount: 0.02,
        createdAt: testDate,
      );
      final preciseExpense3 = ExpenseModel(
        id: 'precise-3',
        name: 'Precise 3',
        amount: 0.03,
        createdAt: testDate,
      );
      final expenses = [preciseExpense1, preciseExpense2, preciseExpense3];

      // Act
      final budget = BudgetModel(expenses: expenses);

      // Assert
      expect(budget.totalExpense, equals(0.06));
    });

    test('should maintain expense order in list', () {
      // Arrange
      final expenses = [
        testExpense3,
        testExpense1,
        testExpense2,
      ]; // Different order

      // Act
      final budget = BudgetModel(expenses: expenses);

      // Assert
      expect(budget.expenses[0], equals(testExpense3));
      expect(budget.expenses[1], equals(testExpense1));
      expect(budget.expenses[2], equals(testExpense2));
    });

    test('should handle duplicate expenses correctly', () {
      // Arrange
      final duplicateExpense = ExpenseModel(
        id: 'duplicate',
        name: 'Duplicate',
        amount: 10.0,
        createdAt: testDate,
      );
      final expenses = [duplicateExpense, duplicateExpense, testExpense1];

      // Act
      final budget = BudgetModel(expenses: expenses);

      // Assert
      expect(budget.expenses.length, equals(3));
      expect(budget.totalExpense, equals(10.0 + 10.0 + 50.25)); // 70.25
    });
  });
}

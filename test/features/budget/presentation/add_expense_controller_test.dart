import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget/features/budget/presentation/add_expense_controller.dart';
import 'package:budget/features/budget/application/budget_service.dart';
import 'package:budget/features/budget/domain/expense_model.dart';

class MockBudgetService implements BudgetService {
  Exception? _addExpenseError;
  bool _isBudgetCreated = true;
  final List<ExpenseModel> _expenses = [];

  void setAddExpenseError(Exception? error) {
    _addExpenseError = error;
  }

  void setBudgetCreated(bool isCreated) {
    _isBudgetCreated = isCreated;
  }

  @override
  Future<bool> isBudgetCreated() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _isBudgetCreated;
  }

  @override
  Future<void> createBudget() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  @override
  Future<List<ExpenseModel>> fetchExpenses() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _expenses;
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (_addExpenseError != null) {
      throw _addExpenseError!;
    }
    _expenses.add(expense);
  }
}

final mockBudgetServiceProvider = Provider<BudgetService>((ref) {
  return MockBudgetService();
});

void main() {
  group('AddExpenseController', () {
    late ProviderContainer container;
    late MockBudgetService mockBudgetService;
    late AddExpenseController controller;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          budgetServiceProvider.overrideWith((ref) => MockBudgetService()),
        ],
      );
      mockBudgetService =
          container.read(budgetServiceProvider) as MockBudgetService;
      controller = container.read(addExpenseControllerProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with data state', () {
      // Act
      final state = container.read(addExpenseControllerProvider);

      // Assert
      expect(state, isA<AsyncData<void>>());
      expect(state.hasValue, isTrue);
    });

    test('should add expense successfully', () async {
      // Arrange
      const expenseName = 'Groceries';
      const expenseAmount = 50.0;

      // Act
      await controller.addExpense(expenseName, expenseAmount);

      // Assert
      final state = container.read(addExpenseControllerProvider);
      expect(state, isA<AsyncData<void>>());
      expect(state.hasValue, isTrue);
      expect(state.hasError, isFalse);
    });

    test('should set loading state when adding expense', () async {
      // Arrange
      const expenseName = 'Gas';
      const expenseAmount = 30.0;

      // Act
      final future = controller.addExpense(expenseName, expenseAmount);

      // Assert - Check loading state
      final loadingState = container.read(addExpenseControllerProvider);
      expect(loadingState, isA<AsyncLoading<void>>());

      // Wait for completion
      await future;

      // Assert - Check final state
      final finalState = container.read(addExpenseControllerProvider);
      expect(finalState, isA<AsyncData<void>>());
    });

    test('should handle error when adding expense fails', () async {
      // Arrange
      const expenseName = 'Invalid Expense';
      const expenseAmount = 100.0;
      final mockError = Exception('Failed to add expense');
      mockBudgetService.setAddExpenseError(mockError);

      // Act
      await controller.addExpense(expenseName, expenseAmount);

      // Assert
      final state = container.read(addExpenseControllerProvider);
      expect(state, isA<AsyncError<void>>());
      expect(state.error, equals(mockError));
      expect(state.hasError, isTrue);
    });

    test('should create expense with correct properties', () async {
      // Arrange
      const expenseName = 'Restaurant';
      const expenseAmount = 75.5;
      final beforeTime = DateTime.now();

      // Act
      await controller.addExpense(expenseName, expenseAmount);

      // Assert
      final state = container.read(addExpenseControllerProvider);
      expect(state, isA<AsyncData<void>>());
      expect(state.hasError, isFalse);

      // Verify the expense was added to the service
      final expenses = await mockBudgetService.fetchExpenses();
      expect(expenses.length, equals(1));

      final addedExpense = expenses.first;
      expect(addedExpense.name, equals(expenseName));
      expect(addedExpense.amount, equals(expenseAmount));
      expect(
        addedExpense.id,
        equals(''),
      ); // ID should be empty as per controller
      expect(addedExpense.createdAt.isAfter(beforeTime), isTrue);
      expect(addedExpense.createdAt.isBefore(DateTime.now()), isTrue);
    });

    test('should handle multiple expense additions', () async {
      // Arrange
      const expense1Name = 'Groceries';
      const expense1Amount = 50.0;
      const expense2Name = 'Gas';
      const expense2Amount = 30.0;

      // Act
      await controller.addExpense(expense1Name, expense1Amount);
      await controller.addExpense(expense2Name, expense2Amount);

      // Assert
      final state = container.read(addExpenseControllerProvider);
      expect(state, isA<AsyncData<void>>());
      expect(state.hasError, isFalse);

      // Verify both expenses were added
      final expenses = await mockBudgetService.fetchExpenses();
      expect(expenses.length, equals(2));
      expect(expenses[0].name, equals(expense1Name));
      expect(expenses[0].amount, equals(expense1Amount));
      expect(expenses[1].name, equals(expense2Name));
      expect(expenses[1].amount, equals(expense2Amount));
    });

    test('should handle zero amount expense', () async {
      // Arrange
      const expenseName = 'Free Item';
      const expenseAmount = 0.0;

      // Act
      await controller.addExpense(expenseName, expenseAmount);

      // Assert
      final state = container.read(addExpenseControllerProvider);
      expect(state, isA<AsyncData<void>>());
      expect(state.hasError, isFalse);

      // Verify the expense was added
      final expenses = await mockBudgetService.fetchExpenses();
      expect(expenses.length, equals(1));
      expect(expenses.first.amount, equals(0.0));
    });

    test('should handle negative amount expense', () async {
      // Arrange
      const expenseName = 'Refund';
      const expenseAmount = -25.0;

      // Act
      await controller.addExpense(expenseName, expenseAmount);

      // Assert
      final state = container.read(addExpenseControllerProvider);
      expect(state, isA<AsyncData<void>>());
      expect(state.hasError, isFalse);

      // Verify the expense was added with negative amount
      final expenses = await mockBudgetService.fetchExpenses();
      expect(expenses.length, equals(1));
      expect(expenses.first.amount, equals(-25.0));
    });

    test('should handle empty expense name', () async {
      // Arrange
      const expenseName = '';
      const expenseAmount = 10.0;

      // Act
      await controller.addExpense(expenseName, expenseAmount);

      // Assert
      final state = container.read(addExpenseControllerProvider);
      expect(state, isA<AsyncData<void>>());
      expect(state.hasError, isFalse);

      // Verify the expense was added with empty name
      final expenses = await mockBudgetService.fetchExpenses();
      expect(expenses.length, equals(1));
      expect(expenses.first.name, equals(''));
    });

    test('should handle very large amount', () async {
      // Arrange
      const expenseName = 'Large Purchase';
      const expenseAmount = 999999.99;

      // Act
      await controller.addExpense(expenseName, expenseAmount);

      // Assert
      final state = container.read(addExpenseControllerProvider);
      expect(state, isA<AsyncData<void>>());
      expect(state.hasError, isFalse);

      // Verify the expense was added with large amount
      final expenses = await mockBudgetService.fetchExpenses();
      expect(expenses.length, equals(1));
      expect(expenses.first.amount, equals(999999.99));
    });

    test('should handle decimal precision correctly', () async {
      // Arrange
      const expenseName = 'Precise Amount';
      const expenseAmount = 123.456;

      // Act
      await controller.addExpense(expenseName, expenseAmount);

      // Assert
      final state = container.read(addExpenseControllerProvider);
      expect(state, isA<AsyncData<void>>());
      expect(state.hasError, isFalse);

      // Verify the expense was added with precise amount
      final expenses = await mockBudgetService.fetchExpenses();
      expect(expenses.length, equals(1));
      expect(expenses.first.amount, equals(123.456));
    });

    test('should maintain state consistency after error recovery', () async {
      // Arrange
      const expenseName = 'Test Expense';
      const expenseAmount = 25.0;
      final mockError = Exception('Temporary error');
      mockBudgetService.setAddExpenseError(mockError);

      // Act - First attempt (should fail)
      await controller.addExpense(expenseName, expenseAmount);
      final errorState = container.read(addExpenseControllerProvider);
      expect(errorState, isA<AsyncError<void>>());

      // Clear error and try again
      mockBudgetService.setAddExpenseError(null);
      await controller.addExpense(expenseName, expenseAmount);

      // Assert - Should recover successfully
      final successState = container.read(addExpenseControllerProvider);
      expect(successState, isA<AsyncData<void>>());
      expect(successState.hasError, isFalse);
    });

    test('should handle concurrent expense additions', () async {
      // Arrange
      const expense1Name = 'Expense 1';
      const expense1Amount = 10.0;
      const expense2Name = 'Expense 2';
      const expense2Amount = 20.0;

      // Act - Start both additions concurrently
      final future1 = controller.addExpense(expense1Name, expense1Amount);
      final future2 = controller.addExpense(expense2Name, expense2Amount);

      // Wait for both to complete
      await Future.wait([future1, future2]);

      // Assert
      final state = container.read(addExpenseControllerProvider);
      expect(state, isA<AsyncData<void>>());
      expect(state.hasError, isFalse);

      // Verify both expenses were added
      final expenses = await mockBudgetService.fetchExpenses();
      expect(expenses.length, equals(2));
    });
  });
}

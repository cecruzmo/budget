import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget/features/budget/presentation/budget_controller.dart';
import 'package:budget/features/budget/application/budget_service.dart';
import 'package:budget/features/budget/domain/expense_model.dart';
import 'package:budget/features/budget/domain/budget_model.dart';

class MockBudgetService implements BudgetService {
  List<ExpenseModel>? _mockExpenses;
  bool _isBudgetCreated = false;
  Exception? _mockError;
  Exception? _createBudgetError;

  void setMockExpenses(List<ExpenseModel> expenses) {
    _mockExpenses = expenses;
    _mockError = null;
  }

  void setMockError(Exception error) {
    _mockError = error;
    _mockExpenses = null;
  }

  void setBudgetCreated(bool isCreated) {
    _isBudgetCreated = isCreated;
  }

  void setCreateBudgetError(Exception error) {
    _createBudgetError = error;
  }

  @override
  Future<bool> isBudgetCreated() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _isBudgetCreated;
  }

  @override
  Future<void> createBudget() async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (_createBudgetError != null) {
      throw _createBudgetError!;
    }
  }

  @override
  Future<List<ExpenseModel>> fetchExpenses() async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (_mockError != null) {
      throw _mockError!;
    }
    return _mockExpenses ?? [];
  }
}

final mockBudgetServiceProvider = Provider<BudgetService>((ref) {
  return MockBudgetService();
});

void main() {
  group('BudgetController', () {
    late ProviderContainer container;
    late MockBudgetService mockBudgetService;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          budgetServiceProvider.overrideWith((ref) => MockBudgetService()),
        ],
      );
      mockBudgetService =
          container.read(budgetServiceProvider) as MockBudgetService;
    });

    tearDown(() {
      container.dispose();
    });

    test('should check if budget is created successfully', () async {
      // Arrange
      mockBudgetService.setBudgetCreated(true);
      final controller = container.read(budgetControllerProvider.notifier);

      // Act
      final result = await controller.isBudgetCreated();

      // Assert
      expect(result, isTrue);
    });

    test('should return false when budget is not created', () async {
      // Arrange
      mockBudgetService.setBudgetCreated(false);
      final controller = container.read(budgetControllerProvider.notifier);

      // Act
      final result = await controller.isBudgetCreated();

      // Assert
      expect(result, isFalse);
    });

    test('should create budget successfully', () async {
      // Arrange
      final controller = container.read(budgetControllerProvider.notifier);

      // Act & Assert
      expect(() => controller.createBudget(), returnsNormally);
    });

    test('should handle create budget error', () async {
      // Arrange
      final mockError = Exception('Failed to create budget');
      mockBudgetService.setCreateBudgetError(mockError);
      final controller = container.read(budgetControllerProvider.notifier);

      // Act & Assert
      expect(() => controller.createBudget(), throwsA(equals(mockError)));
    });

    test('should handle state changes in isBudgetCreated', () async {
      // Arrange
      final controller = container.read(budgetControllerProvider.notifier);

      // Act & Assert (Initial state - false)
      mockBudgetService.setBudgetCreated(false);
      final initialResult = await controller.isBudgetCreated();
      expect(initialResult, isFalse);

      // Act & Assert (Changed state - true)
      mockBudgetService.setBudgetCreated(true);
      final changedResult = await controller.isBudgetCreated();
      expect(changedResult, isTrue);
    });

    test('should initialize with loading state', () {
      // Arrange: (Setup done in setUp)
      // Act
      final state = container.read(budgetControllerProvider);

      // Assert
      expect(state, isA<AsyncLoading<BudgetModel>>());
    });

    test('should fetch expenses successfully and calculate total', () async {
      // Arrange
      final mockExpenses = [
        ExpenseModel(
          id: '1',
          name: 'Groceries',
          amount: 50.0,
          createdAt: DateTime(2024, 1, 1),
        ),
        ExpenseModel(
          id: '2',
          name: 'Gas',
          amount: 30.0,
          createdAt: DateTime(2024, 1, 2),
        ),
      ];
      mockBudgetService.setMockExpenses(mockExpenses);
      final controller = container.read(budgetControllerProvider.notifier);

      // Act
      expect(
        container.read(budgetControllerProvider),
        isA<AsyncLoading<BudgetModel>>(),
      );
      await controller.fetchExpenses();

      // Assert
      final state = container.read(budgetControllerProvider);
      expect(state, isA<AsyncData<BudgetModel>>());
      final budgetModel = state.value;
      expect(budgetModel, isNotNull);
      expect(budgetModel!.expenses.length, equals(2));
      expect(budgetModel.totalExpense, equals(80.0));
      expect(budgetModel.expenses[0].id, equals('1'));
      expect(budgetModel.expenses[0].name, equals('Groceries'));
      expect(budgetModel.expenses[0].amount, equals(50.0));
      expect(budgetModel.expenses[1].id, equals('2'));
      expect(budgetModel.expenses[1].name, equals('Gas'));
      expect(budgetModel.expenses[1].amount, equals(30.0));
    });

    test('should handle empty expenses list with zero total', () async {
      // Arrange
      mockBudgetService.setMockExpenses([]);
      final controller = container.read(budgetControllerProvider.notifier);

      // Act
      await controller.fetchExpenses();

      // Assert
      final state = container.read(budgetControllerProvider);
      expect(state, isA<AsyncData<BudgetModel>>());
      final budgetModel = state.value;
      expect(budgetModel, isNotNull);
      expect(budgetModel!.expenses.isEmpty, isTrue);
      expect(budgetModel.totalExpense, equals(0.0));
    });

    test('should handle fetch expenses error', () async {
      // Arrange
      final mockError = Exception('Failed to fetch expenses');
      mockBudgetService.setMockError(mockError);
      final controller = container.read(budgetControllerProvider.notifier);

      // Act
      await controller.fetchExpenses();

      // Assert
      final state = container.read(budgetControllerProvider);
      expect(state, isA<AsyncError<BudgetModel>>());
      final error = state.error;
      expect(error, isNotNull);
      expect(error, equals(mockError));
    });

    test('should handle network timeout error', () async {
      // Arrange
      final mockError = Exception('Network timeout');
      mockBudgetService.setMockError(mockError);
      final controller = container.read(budgetControllerProvider.notifier);

      // Act
      await controller.fetchExpenses();

      // Assert
      final state = container.read(budgetControllerProvider);
      expect(state, isA<AsyncError<BudgetModel>>());
      expect(state.error, equals(mockError));
    });

    test('should transition through loading state during fetch', () async {
      // Arrange
      final mockExpenses = [
        ExpenseModel(
          id: '1',
          name: 'Test Expense',
          amount: 25.0,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];
      mockBudgetService.setMockExpenses(mockExpenses);
      final controller = container.read(budgetControllerProvider.notifier);

      // Act
      final fetchFuture = controller.fetchExpenses();
      expect(
        container.read(budgetControllerProvider),
        isA<AsyncLoading<BudgetModel>>(),
      );
      await fetchFuture;

      // Assert
      final state = container.read(budgetControllerProvider);
      expect(state, isA<AsyncData<BudgetModel>>());
    });

    test('should handle multiple consecutive fetch calls', () async {
      // Arrange
      final firstExpenses = [
        ExpenseModel(
          id: '1',
          name: 'First Expense',
          amount: 10.0,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];
      final secondExpenses = [
        ExpenseModel(
          id: '2',
          name: 'Second Expense',
          amount: 20.0,
          createdAt: DateTime(2024, 1, 2),
        ),
      ];
      final controller = container.read(budgetControllerProvider.notifier);

      // Act & Assert (First fetch)
      mockBudgetService.setMockExpenses(firstExpenses);
      await controller.fetchExpenses();
      var state = container.read(budgetControllerProvider);
      expect(state, isA<AsyncData<BudgetModel>>());
      expect(state.value!.expenses.length, equals(1));
      expect(state.value!.totalExpense, equals(10.0));
      expect(state.value!.expenses[0].name, equals('First Expense'));

      // Act & Assert (Second fetch)
      mockBudgetService.setMockExpenses(secondExpenses);
      await controller.fetchExpenses();
      state = container.read(budgetControllerProvider);
      expect(state, isA<AsyncData<BudgetModel>>());
      expect(state.value!.expenses.length, equals(1));
      expect(state.value!.totalExpense, equals(20.0));
      expect(state.value!.expenses[0].name, equals('Second Expense'));
    });

    test('should handle fetch after error state', () async {
      // Arrange
      final mockError = Exception('Initial error');
      mockBudgetService.setMockError(mockError);
      final controller = container.read(budgetControllerProvider.notifier);

      // Act & Assert (Error fetch)
      await controller.fetchExpenses();
      var state = container.read(budgetControllerProvider);
      expect(state, isA<AsyncError<BudgetModel>>());

      // Arrange (set up success)
      final mockExpenses = [
        ExpenseModel(
          id: '1',
          name: 'Recovery Expense',
          amount: 15.0,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];
      mockBudgetService.setMockExpenses(mockExpenses);

      // Act & Assert (Success fetch)
      await controller.fetchExpenses();
      state = container.read(budgetControllerProvider);
      expect(state, isA<AsyncData<BudgetModel>>());
      expect(state.value!.expenses.length, equals(1));
      expect(state.value!.totalExpense, equals(15.0));
      expect(state.value!.expenses[0].name, equals('Recovery Expense'));
    });

    test('should maintain state consistency across multiple reads', () async {
      // Arrange
      final mockExpenses = [
        ExpenseModel(
          id: '1',
          name: 'Consistent Expense',
          amount: 100.0,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];
      mockBudgetService.setMockExpenses(mockExpenses);
      final controller = container.read(budgetControllerProvider.notifier);

      // Act
      await controller.fetchExpenses();

      // Assert
      final state1 = container.read(budgetControllerProvider);
      final state2 = container.read(budgetControllerProvider);
      final state3 = container.read(budgetControllerProvider);
      expect(state1, equals(state2));
      expect(state2, equals(state3));
      expect(state1.value!.expenses.length, equals(1));
      expect(state1.value!.totalExpense, equals(100.0));
      expect(state1.value!.expenses[0].amount, equals(100.0));
    });

    test('should handle null expenses gracefully', () async {
      // Arrange
      mockBudgetService.setMockExpenses([]);
      final controller = container.read(budgetControllerProvider.notifier);

      // Act
      await controller.fetchExpenses();

      // Assert
      final state = container.read(budgetControllerProvider);
      expect(state, isA<AsyncData<BudgetModel>>());
      expect(state.value, isNotNull);
      expect(state.value!.expenses.isEmpty, isTrue);
      expect(state.value!.totalExpense, equals(0.0));
    });

    test(
      'should calculate total expense correctly with multiple expenses',
      () async {
        // Arrange
        final mockExpenses = [
          ExpenseModel(
            id: '1',
            name: 'Expense 1',
            amount: 25.50,
            createdAt: DateTime(2024, 1, 1),
          ),
          ExpenseModel(
            id: '2',
            name: 'Expense 2',
            amount: 75.25,
            createdAt: DateTime(2024, 1, 2),
          ),
          ExpenseModel(
            id: '3',
            name: 'Expense 3',
            amount: 100.00,
            createdAt: DateTime(2024, 1, 3),
          ),
        ];
        mockBudgetService.setMockExpenses(mockExpenses);
        final controller = container.read(budgetControllerProvider.notifier);

        // Act
        await controller.fetchExpenses();

        // Assert
        final state = container.read(budgetControllerProvider);
        expect(state, isA<AsyncData<BudgetModel>>());
        final budgetModel = state.value;
        expect(budgetModel, isNotNull);
        expect(budgetModel!.expenses.length, equals(3));
        expect(budgetModel.totalExpense, equals(200.75));
      },
    );

    test('should handle copyWith method correctly', () async {
      // Arrange
      final mockExpenses = [
        ExpenseModel(
          id: '1',
          name: 'Original Expense',
          amount: 50.0,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];
      mockBudgetService.setMockExpenses(mockExpenses);
      final controller = container.read(budgetControllerProvider.notifier);

      // Act
      await controller.fetchExpenses();
      final originalBudget = container.read(budgetControllerProvider).value!;
      final updatedBudget = originalBudget.copyWith(
        expenses: [
          ExpenseModel(
            id: '2',
            name: 'Updated Expense',
            amount: 75.0,
            createdAt: DateTime(2024, 1, 2),
          ),
        ],
      );

      // Assert
      expect(updatedBudget.expenses.length, equals(1));
      expect(updatedBudget.totalExpense, equals(75.0));
      expect(updatedBudget.expenses[0].name, equals('Updated Expense'));
      expect(originalBudget.expenses[0].name, equals('Original Expense'));
    });
  });
}

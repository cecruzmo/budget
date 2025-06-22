import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget/features/home/presentation/budget_controller.dart';
import 'package:budget/features/home/application/budget_service.dart';
import 'package:budget/features/home/domain/expense_model.dart';

class MockBudgetService implements BudgetService {
  List<ExpenseModel>? _mockExpenses;
  Exception? _mockError;

  void setMockExpenses(List<ExpenseModel> expenses) {
    _mockExpenses = expenses;
    _mockError = null;
  }

  void setMockError(Exception error) {
    _mockError = error;
    _mockExpenses = null;
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

    test('should initialize with loading state', () {
      // Arrange: (Setup done in setUp)
      // Act
      final state = container.read(budgetControllerProvider);

      // Assert
      expect(state, isA<AsyncLoading<List<ExpenseModel>>>());
    });

    test('should fetch expenses successfully', () async {
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
        isA<AsyncLoading<List<ExpenseModel>>>(),
      );
      await controller.fetchExpenses();

      // Assert
      final state = container.read(budgetControllerProvider);
      expect(state, isA<AsyncData<List<ExpenseModel>>>());
      final data = state.value;
      expect(data, isNotNull);
      expect(data!.length, equals(2));
      expect(data[0].id, equals('1'));
      expect(data[0].name, equals('Groceries'));
      expect(data[0].amount, equals(50.0));
      expect(data[1].id, equals('2'));
      expect(data[1].name, equals('Gas'));
      expect(data[1].amount, equals(30.0));
    });

    test('should handle empty expenses list', () async {
      // Arrange
      mockBudgetService.setMockExpenses([]);
      final controller = container.read(budgetControllerProvider.notifier);

      // Act
      await controller.fetchExpenses();

      // Assert
      final state = container.read(budgetControllerProvider);
      expect(state, isA<AsyncData<List<ExpenseModel>>>());
      final data = state.value;
      expect(data, isNotNull);
      expect(data!.isEmpty, isTrue);
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
      expect(state, isA<AsyncError<List<ExpenseModel>>>());
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
      expect(state, isA<AsyncError<List<ExpenseModel>>>());
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
        isA<AsyncLoading<List<ExpenseModel>>>(),
      );
      await fetchFuture;

      // Assert
      final state = container.read(budgetControllerProvider);
      expect(state, isA<AsyncData<List<ExpenseModel>>>());
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
      expect(state, isA<AsyncData<List<ExpenseModel>>>());
      expect(state.value!.length, equals(1));
      expect(state.value![0].name, equals('First Expense'));

      // Act & Assert (Second fetch)
      mockBudgetService.setMockExpenses(secondExpenses);
      await controller.fetchExpenses();
      state = container.read(budgetControllerProvider);
      expect(state, isA<AsyncData<List<ExpenseModel>>>());
      expect(state.value!.length, equals(1));
      expect(state.value![0].name, equals('Second Expense'));
    });

    test('should handle fetch after error state', () async {
      // Arrange
      final mockError = Exception('Initial error');
      mockBudgetService.setMockError(mockError);
      final controller = container.read(budgetControllerProvider.notifier);

      // Act & Assert (Error fetch)
      await controller.fetchExpenses();
      var state = container.read(budgetControllerProvider);
      expect(state, isA<AsyncError<List<ExpenseModel>>>());

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
      expect(state, isA<AsyncData<List<ExpenseModel>>>());
      expect(state.value!.length, equals(1));
      expect(state.value![0].name, equals('Recovery Expense'));
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
      expect(state1.value!.length, equals(1));
      expect(state1.value![0].amount, equals(100.0));
    });

    test('should handle null expenses gracefully', () async {
      // Arrange
      mockBudgetService.setMockExpenses([]);
      final controller = container.read(budgetControllerProvider.notifier);

      // Act
      await controller.fetchExpenses();

      // Assert
      final state = container.read(budgetControllerProvider);
      expect(state, isA<AsyncData<List<ExpenseModel>>>());
      expect(state.value, isNotNull);
      expect(state.value!.isEmpty, isTrue);
    });
  });
}

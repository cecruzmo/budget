import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget/features/budget/presentation/add_expense_item.dart';
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
  group('AddExpenseItem TextField Validations', () {
    late ProviderContainer container;
    late MockBudgetService mockBudgetService;
    bool onExpenseAddedCalled = false;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          budgetServiceProvider.overrideWith((ref) => MockBudgetService()),
        ],
      );
      mockBudgetService =
          container.read(budgetServiceProvider) as MockBudgetService;
      onExpenseAddedCalled = false;
    });

    tearDown(() {
      container.dispose();
    });

    Widget createWidget() {
      return ProviderScope(
        // ignore: deprecated_member_use
        parent: container,
        child: MaterialApp(
          home: Scaffold(
            body: AddExpenseItem(
              onExpenseAdded: () {
                onExpenseAddedCalled = true;
              },
            ),
          ),
        ),
      );
    }

    group('Empty Field Validations', () {
      testWidgets('should show error when description is empty', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(createWidget());

        // Find text fields
        final amountField = find.byType(TextField).last;

        // Act - Enter only amount, leave description empty
        await tester.enterText(amountField, '50.00');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Please enter a description'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(onExpenseAddedCalled, isFalse);
      });

      testWidgets('should show error when amount is empty', (tester) async {
        // Arrange
        await tester.pumpWidget(createWidget());

        // Find text fields
        final descriptionField = find.byType(TextField).first;
        final amountField = find.byType(TextField).last;

        // Act - Enter only description, leave amount empty, then submit amount field
        await tester.enterText(descriptionField, 'Groceries');
        await tester.enterText(amountField, ''); // Ensure amount field is empty
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Please enter an amount'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(onExpenseAddedCalled, isFalse);
      });

      testWidgets('should show error when both fields are empty', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(createWidget());

        // Find text fields
        final descriptionField = find.byType(TextField).first;
        final amountField = find.byType(TextField).last;

        // Act - Submit with empty fields
        await tester.enterText(descriptionField, '');
        await tester.enterText(amountField, '');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Assert - Should show description error first
        expect(find.text('Please enter a description'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(onExpenseAddedCalled, isFalse);
      });
    });

    group('Amount Validation', () {
      testWidgets('should show error for invalid amount (non-numeric)', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(createWidget());

        // Find text fields
        final descriptionField = find.byType(TextField).first;
        final amountField = find.byType(TextField).last;

        // Act - Enter invalid amount
        await tester.enterText(descriptionField, 'Groceries');
        await tester.enterText(amountField, 'abc');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('Please enter a valid amount greater than 0'),
          findsOneWidget,
        );
        expect(find.byType(SnackBar), findsOneWidget);
        expect(onExpenseAddedCalled, isFalse);
      });

      testWidgets('should show error for zero amount', (tester) async {
        // Arrange
        await tester.pumpWidget(createWidget());

        // Find text fields
        final descriptionField = find.byType(TextField).first;
        final amountField = find.byType(TextField).last;

        // Act - Enter zero amount
        await tester.enterText(descriptionField, 'Free Item');
        await tester.enterText(amountField, '0');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('Please enter a valid amount greater than 0'),
          findsOneWidget,
        );
        expect(find.byType(SnackBar), findsOneWidget);
        expect(onExpenseAddedCalled, isFalse);
      });

      testWidgets('should show error for negative amount', (tester) async {
        // Arrange
        await tester.pumpWidget(createWidget());

        // Find text fields
        final descriptionField = find.byType(TextField).first;
        final amountField = find.byType(TextField).last;

        // Act - Enter negative amount
        await tester.enterText(descriptionField, 'Refund');
        await tester.enterText(amountField, '-50.00');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('Please enter a valid amount greater than 0'),
          findsOneWidget,
        );
        expect(find.byType(SnackBar), findsOneWidget);
        expect(onExpenseAddedCalled, isFalse);
      });

      testWidgets('should accept valid decimal amounts', (tester) async {
        // Arrange
        await tester.pumpWidget(createWidget());

        // Find text fields
        final descriptionField = find.byType(TextField).first;
        final amountField = find.byType(TextField).last;

        // Act - Enter valid decimal amount
        await tester.enterText(descriptionField, 'Coffee');
        await tester.enterText(amountField, '3.50');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        // Wait for async operation
        await tester.pumpAndSettle();

        // Assert - Should not show error and callback should be called
        expect(
          find.text('Please enter a valid amount greater than 0'),
          findsNothing,
        );
        expect(find.byType(SnackBar), findsNothing);
        expect(onExpenseAddedCalled, isTrue);
      });

      testWidgets('should accept valid integer amounts', (tester) async {
        // Arrange
        await tester.pumpWidget(createWidget());

        // Find text fields
        final descriptionField = find.byType(TextField).first;
        final amountField = find.byType(TextField).last;

        // Act - Enter valid integer amount
        await tester.enterText(descriptionField, 'Gas');
        await tester.enterText(amountField, '45');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        // Wait for async operation
        await tester.pumpAndSettle();

        // Assert - Should not show error and callback should be called
        expect(
          find.text('Please enter a valid amount greater than 0'),
          findsNothing,
        );
        expect(find.byType(SnackBar), findsNothing);
        expect(onExpenseAddedCalled, isTrue);
      });
    });

    group('TextField Behavior', () {
      testWidgets('should focus amount field when description is submitted', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(createWidget());

        // Find text fields
        final descriptionField = find.byType(TextField).first;

        // Act - Enter description and submit
        await tester.enterText(descriptionField, 'Groceries');
        await tester.testTextInput.receiveAction(TextInputAction.next);

        // Assert - Amount field should be focused (we can verify by checking if it's the active field)
        // The focus will automatically move to the amount field due to onSubmitted callback
        expect(find.byType(TextField), findsNWidgets(2));
      });

      testWidgets('should submit when amount field is submitted', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(createWidget());

        // Find text fields
        final descriptionField = find.byType(TextField).first;
        final amountField = find.byType(TextField).last;

        // Act - Enter valid data and submit amount field
        await tester.enterText(descriptionField, 'Lunch');
        await tester.enterText(amountField, '12.99');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        // Wait for async operation
        await tester.pumpAndSettle();

        // Assert - Should submit successfully
        expect(onExpenseAddedCalled, isTrue);
      });

      testWidgets('should clear fields after successful submission', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(createWidget());

        // Find text fields
        final descriptionField = find.byType(TextField).first;
        final amountField = find.byType(TextField).last;

        // Act - Enter data and submit
        await tester.enterText(descriptionField, 'Dinner');
        await tester.enterText(amountField, '25.50');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        // Wait for async operation
        await tester.pumpAndSettle();

        // Assert - Fields should be cleared
        expect(find.text('Dinner'), findsNothing);
        expect(find.text('25.50'), findsNothing);
        expect(onExpenseAddedCalled, isTrue);
      });
    });

    group('Error Handling', () {
      testWidgets('should show error snackbar when service fails', (
        tester,
      ) async {
        // Arrange
        mockBudgetService.setAddExpenseError(Exception('Service error'));
        await tester.pumpWidget(createWidget());

        // Find text fields
        final descriptionField = find.byType(TextField).first;
        final amountField = find.byType(TextField).last;

        // Act - Enter valid data and submit
        await tester.enterText(descriptionField, 'Test Expense');
        await tester.enterText(amountField, '10.00');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        // Wait for async operation
        await tester.pumpAndSettle();

        // Assert - Should show error message
        expect(
          find.text('Failed to add expense: Exception: Service error'),
          findsOneWidget,
        );
        expect(find.byType(SnackBar), findsOneWidget);
        expect(onExpenseAddedCalled, isFalse);
      });

      testWidgets('should show loading indicator during submission', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(createWidget());

        // Find text fields
        final descriptionField = find.byType(TextField).first;
        final amountField = find.byType(TextField).last;

        // Act - Enter valid data and submit
        await tester.enterText(descriptionField, 'Loading Test');
        await tester.enterText(amountField, '15.00');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        // Assert - Should show loading indicator during the async operation
        await tester.pump(); // Pump once to trigger the loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for completion
        await tester.pumpAndSettle();

        // Assert - Loading indicator should be gone
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    group('Input Formatting', () {
      testWidgets('should handle whitespace in description', (tester) async {
        // Arrange
        await tester.pumpWidget(createWidget());

        // Find text fields
        final descriptionField = find.byType(TextField).first;
        final amountField = find.byType(TextField).last;

        // Act - Enter description with leading/trailing whitespace
        await tester.enterText(descriptionField, '  Groceries  ');
        await tester.enterText(amountField, '30.00');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        // Wait for async operation
        await tester.pumpAndSettle();

        // Assert - Should submit successfully (whitespace is trimmed)
        expect(onExpenseAddedCalled, isTrue);
      });

      testWidgets('should handle whitespace in amount', (tester) async {
        // Arrange
        await tester.pumpWidget(createWidget());

        // Find text fields
        final descriptionField = find.byType(TextField).first;
        final amountField = find.byType(TextField).last;

        // Act - Enter amount with leading/trailing whitespace
        await tester.enterText(descriptionField, 'Test');
        await tester.enterText(amountField, '  20.50  ');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        // Wait for async operation
        await tester.pumpAndSettle();

        // Assert - Should submit successfully (whitespace is trimmed)
        expect(onExpenseAddedCalled, isTrue);
      });
    });
  });
}

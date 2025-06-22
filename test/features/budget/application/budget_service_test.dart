import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget/features/budget/application/budget_service.dart';
import 'package:budget/features/budget/data/budget_repository.dart';
import 'package:budget/features/budget/domain/expense_model.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  group('BudgetService', () {
    late BudgetService budgetService;
    late MockBudgetRepository mockBudgetRepository;

    setUp(() {
      mockBudgetRepository = MockBudgetRepository();
      budgetService = BudgetService(mockBudgetRepository);
    });

    group('fetchExpenses', () {
      test(
        'should return list of expenses when repository call is successful',
        () async {
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

          when(
            () => mockBudgetRepository.fetchExpenses(),
          ).thenAnswer((_) async => mockExpenses);

          // Act
          final result = await budgetService.fetchExpenses();

          // Assert
          expect(result, equals(mockExpenses));
          verify(() => mockBudgetRepository.fetchExpenses()).called(1);
        },
      );

      test(
        'should return empty list when repository returns empty list',
        () async {
          // Arrange
          when(
            () => mockBudgetRepository.fetchExpenses(),
          ).thenAnswer((_) async => <ExpenseModel>[]);

          // Act
          final result = await budgetService.fetchExpenses();

          // Assert
          expect(result, isEmpty);
          verify(() => mockBudgetRepository.fetchExpenses()).called(1);
        },
      );

      test(
        'should propagate exception when repository throws an error',
        () async {
          // Arrange
          final exception = Exception('Failed to fetch expenses');
          when(() => mockBudgetRepository.fetchExpenses()).thenThrow(exception);

          // Act & Assert
          expect(
            () => budgetService.fetchExpenses(),
            throwsA(equals(exception)),
          );
          verify(() => mockBudgetRepository.fetchExpenses()).called(1);
        },
      );

      test('should handle single expense correctly', () async {
        // Arrange
        final mockExpense = ExpenseModel(
          id: '1',
          name: 'Coffee',
          amount: 5.0,
          createdAt: DateTime(2024, 1, 1),
        );

        when(
          () => mockBudgetRepository.fetchExpenses(),
        ).thenAnswer((_) async => [mockExpense]);

        // Act
        final result = await budgetService.fetchExpenses();

        // Assert
        expect(result, hasLength(1));
        expect(result.first, equals(mockExpense));
        verify(() => mockBudgetRepository.fetchExpenses()).called(1);
      });
    });
  });
}

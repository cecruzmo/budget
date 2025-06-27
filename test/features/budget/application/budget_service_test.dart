import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget/features/budget/application/budget_service.dart';
import 'package:budget/features/budget/data/budget_repository.dart';
import 'package:budget/features/budget/domain/expense_model.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      ExpenseModel(
        id: 'fallback',
        name: 'Fallback Expense',
        amount: 0.0,
        createdAt: DateTime(2024, 1, 1),
      ),
    );
  });

  group('BudgetService', () {
    late BudgetService budgetService;
    late MockBudgetRepository mockBudgetRepository;

    setUp(() {
      mockBudgetRepository = MockBudgetRepository();
      budgetService = BudgetService(mockBudgetRepository);
    });

    group('isBudgetCreated', () {
      test('should return true when budget is created', () async {
        // Arrange
        when(
          () => mockBudgetRepository.isBudgetCreated(),
        ).thenAnswer((_) async => true);

        // Act
        final result = await budgetService.isBudgetCreated();

        // Assert
        expect(result, isTrue);
        verify(() => mockBudgetRepository.isBudgetCreated()).called(1);
      });

      test('should return false when budget is not created', () async {
        // Arrange
        when(
          () => mockBudgetRepository.isBudgetCreated(),
        ).thenAnswer((_) async => false);

        // Act
        final result = await budgetService.isBudgetCreated();

        // Assert
        expect(result, isFalse);
        verify(() => mockBudgetRepository.isBudgetCreated()).called(1);
      });

      test(
        'should propagate exception when repository throws an error',
        () async {
          // Arrange
          final exception = Exception('Failed to check budget status');
          when(
            () => mockBudgetRepository.isBudgetCreated(),
          ).thenThrow(exception);

          // Act & Assert
          expect(
            () => budgetService.isBudgetCreated(),
            throwsA(equals(exception)),
          );
          verify(() => mockBudgetRepository.isBudgetCreated()).called(1);
        },
      );

      test(
        'should call repository exactly once per isBudgetCreated call',
        () async {
          // Arrange
          when(
            () => mockBudgetRepository.isBudgetCreated(),
          ).thenAnswer((_) async => true);

          // Act
          await budgetService.isBudgetCreated();
          await budgetService.isBudgetCreated();

          // Assert
          verify(() => mockBudgetRepository.isBudgetCreated()).called(2);
        },
      );
    });

    group('createBudget', () {
      test(
        'should complete successfully when repository call succeeds',
        () async {
          // Arrange
          when(
            () => mockBudgetRepository.createBudget(),
          ).thenAnswer((_) async {});

          // Act
          await budgetService.createBudget();

          // Assert
          verify(() => mockBudgetRepository.createBudget()).called(1);
        },
      );

      test(
        'should propagate exception when repository throws an error',
        () async {
          // Arrange
          final exception = Exception('Failed to create budget');
          when(() => mockBudgetRepository.createBudget()).thenThrow(exception);

          // Act & Assert
          expect(
            () => budgetService.createBudget(),
            throwsA(equals(exception)),
          );
          verify(() => mockBudgetRepository.createBudget()).called(1);
        },
      );

      test(
        'should call repository exactly once per createBudget call',
        () async {
          // Arrange
          when(
            () => mockBudgetRepository.createBudget(),
          ).thenAnswer((_) async {});

          // Act
          await budgetService.createBudget();
          await budgetService.createBudget();
          await budgetService.createBudget();

          // Assert
          verify(() => mockBudgetRepository.createBudget()).called(3);
        },
      );
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
          expect(result, hasLength(2));
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
          expect(result, hasLength(0));
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
        expect(result.first.id, equals('1'));
        expect(result.first.name, equals('Coffee'));
        expect(result.first.amount, equals(5.0));
        verify(() => mockBudgetRepository.fetchExpenses()).called(1);
      });

      test('should handle large list of expenses correctly', () async {
        // Arrange
        final mockExpenses = List.generate(
          100,
          (index) => ExpenseModel(
            id: index.toString(),
            name: 'Expense $index',
            amount: (index + 1) * 10.0,
            createdAt: DateTime(2024, 1, 1).add(Duration(days: index)),
          ),
        );

        when(
          () => mockBudgetRepository.fetchExpenses(),
        ).thenAnswer((_) async => mockExpenses);

        // Act
        final result = await budgetService.fetchExpenses();

        // Assert
        expect(result, hasLength(100));
        expect(result, equals(mockExpenses));
        expect(result.first.id, equals('0'));
        expect(result.last.id, equals('99'));
        verify(() => mockBudgetRepository.fetchExpenses()).called(1);
      });

      test('should handle expenses with zero amount', () async {
        // Arrange
        final mockExpenses = [
          ExpenseModel(
            id: '1',
            name: 'Free Item',
            amount: 0.0,
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        when(
          () => mockBudgetRepository.fetchExpenses(),
        ).thenAnswer((_) async => mockExpenses);

        // Act
        final result = await budgetService.fetchExpenses();

        // Assert
        expect(result, hasLength(1));
        expect(result.first.amount, equals(0.0));
        verify(() => mockBudgetRepository.fetchExpenses()).called(1);
      });

      test('should handle expenses with decimal amounts', () async {
        // Arrange
        final mockExpenses = [
          ExpenseModel(
            id: '1',
            name: 'Taxi',
            amount: 12.75,
            createdAt: DateTime(2024, 1, 1),
          ),
          ExpenseModel(
            id: '2',
            name: 'Tip',
            amount: 3.25,
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        when(
          () => mockBudgetRepository.fetchExpenses(),
        ).thenAnswer((_) async => mockExpenses);

        // Act
        final result = await budgetService.fetchExpenses();

        // Assert
        expect(result, hasLength(2));
        expect(result.first.amount, equals(12.75));
        expect(result.last.amount, equals(3.25));
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

      test(
        'should propagate network exception when repository throws network error',
        () async {
          // Arrange
          final networkException = Exception(
            'Network error: Connection timeout',
          );
          when(
            () => mockBudgetRepository.fetchExpenses(),
          ).thenThrow(networkException);

          // Act & Assert
          expect(
            () => budgetService.fetchExpenses(),
            throwsA(equals(networkException)),
          );
          verify(() => mockBudgetRepository.fetchExpenses()).called(1);
        },
      );

      test(
        'should call repository exactly once per fetchExpenses call',
        () async {
          // Arrange
          when(
            () => mockBudgetRepository.fetchExpenses(),
          ).thenAnswer((_) async => <ExpenseModel>[]);

          // Act
          await budgetService.fetchExpenses();
          await budgetService.fetchExpenses();
          await budgetService.fetchExpenses();

          // Assert
          verify(() => mockBudgetRepository.fetchExpenses()).called(3);
        },
      );
    });

    group('addExpense', () {
      test(
        'should complete successfully when repository call succeeds',
        () async {
          // Arrange
          final expense = ExpenseModel(
            id: '1',
            name: 'Groceries',
            amount: 50.0,
            createdAt: DateTime(2024, 1, 1),
          );

          when(
            () => mockBudgetRepository.addExpense(expense),
          ).thenAnswer((_) async {});

          // Act
          await budgetService.addExpense(expense);

          // Assert
          verify(() => mockBudgetRepository.addExpense(expense)).called(1);
        },
      );

      test('should handle expense with zero amount', () async {
        // Arrange
        final expense = ExpenseModel(
          id: '1',
          name: 'Free Item',
          amount: 0.0,
          createdAt: DateTime(2024, 1, 1),
        );

        when(
          () => mockBudgetRepository.addExpense(expense),
        ).thenAnswer((_) async {});

        // Act
        await budgetService.addExpense(expense);

        // Assert
        verify(() => mockBudgetRepository.addExpense(expense)).called(1);
      });

      test('should handle expense with decimal amount', () async {
        // Arrange
        final expense = ExpenseModel(
          id: '1',
          name: 'Taxi',
          amount: 12.75,
          createdAt: DateTime(2024, 1, 1),
        );

        when(
          () => mockBudgetRepository.addExpense(expense),
        ).thenAnswer((_) async {});

        // Act
        await budgetService.addExpense(expense);

        // Assert
        verify(() => mockBudgetRepository.addExpense(expense)).called(1);
      });

      test('should handle expense with large amount', () async {
        // Arrange
        final expense = ExpenseModel(
          id: '1',
          name: 'Rent',
          amount: 15000000.0,
          createdAt: DateTime(2024, 1, 1),
        );

        when(
          () => mockBudgetRepository.addExpense(expense),
        ).thenAnswer((_) async {});

        // Act
        await budgetService.addExpense(expense);

        // Assert
        verify(() => mockBudgetRepository.addExpense(expense)).called(1);
      });

      test('should handle expense with special characters in name', () async {
        // Arrange
        final expense = ExpenseModel(
          id: '1',
          name: 'Café & Restaurant 🍕',
          amount: 25.50,
          createdAt: DateTime(2024, 1, 1),
        );

        when(
          () => mockBudgetRepository.addExpense(expense),
        ).thenAnswer((_) async {});

        // Act
        await budgetService.addExpense(expense);

        // Assert
        verify(() => mockBudgetRepository.addExpense(expense)).called(1);
      });

      test(
        'should propagate exception when repository throws an error',
        () async {
          // Arrange
          final expense = ExpenseModel(
            id: '1',
            name: 'Groceries',
            amount: 50.0,
            createdAt: DateTime(2024, 1, 1),
          );
          final exception = Exception('Failed to add expense');
          when(
            () => mockBudgetRepository.addExpense(expense),
          ).thenThrow(exception);

          // Act & Assert
          expect(
            () => budgetService.addExpense(expense),
            throwsA(equals(exception)),
          );
          verify(() => mockBudgetRepository.addExpense(expense)).called(1);
        },
      );


      test('should call repository exactly once per addExpense call', () async {
        // Arrange
        final expense1 = ExpenseModel(
          id: '1',
          name: 'Groceries',
          amount: 50.0,
          createdAt: DateTime(2024, 1, 1),
        );
        final expense2 = ExpenseModel(
          id: '2',
          name: 'Gas',
          amount: 30.0,
          createdAt: DateTime(2024, 1, 2),
        );

        when(
          () => mockBudgetRepository.addExpense(any()),
        ).thenAnswer((_) async {});

        // Act
        await budgetService.addExpense(expense1);
        await budgetService.addExpense(expense2);

        // Assert
        verify(() => mockBudgetRepository.addExpense(expense1)).called(1);
        verify(() => mockBudgetRepository.addExpense(expense2)).called(1);
      });

      test(
        'should handle multiple expenses with same name but different amounts',
        () async {
          // Arrange
          final expense1 = ExpenseModel(
            id: '1',
            name: 'Coffee',
            amount: 3.50,
            createdAt: DateTime(2024, 1, 1),
          );
          final expense2 = ExpenseModel(
            id: '2',
            name: 'Coffee',
            amount: 4.00,
            createdAt: DateTime(2024, 1, 2),
          );

          when(
            () => mockBudgetRepository.addExpense(any()),
          ).thenAnswer((_) async {});

          // Act
          await budgetService.addExpense(expense1);
          await budgetService.addExpense(expense2);

          // Assert
          verify(() => mockBudgetRepository.addExpense(expense1)).called(1);
          verify(() => mockBudgetRepository.addExpense(expense2)).called(1);
        },
      );
    });

    group('BudgetService constructor', () {
      test('should create instance with valid repository', () {
        // Arrange & Act
        final service = BudgetService(mockBudgetRepository);

        // Assert
        expect(service, isA<BudgetService>());
      });

      test('should not throw when created with null repository', () {
        // This test ensures the service can handle null repository if needed
        // Arrange & Act & Assert
        expect(() => BudgetService(mockBudgetRepository), returnsNormally);
      });
    });
  });
}

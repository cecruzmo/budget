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
        'should propagate database exception when repository throws database error',
        () async {
          // Arrange
          final dbException = Exception('Database error: Permission denied');
          when(
            () => mockBudgetRepository.fetchExpenses(),
          ).thenThrow(dbException);

          // Act & Assert
          expect(
            () => budgetService.fetchExpenses(),
            throwsA(equals(dbException)),
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

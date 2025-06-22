import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budget/features/budget/data/firebase_budget_repository.dart';
import 'package:budget/features/budget/data/budget_repository.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockCollectionReferenceExpenses extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

void main() {
  group('FirebaseBudgetRepository', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockBudgetsCollection;
    late MockQuerySnapshot mockBudgetQuerySnapshot;
    late MockQueryDocumentSnapshot mockBudgetDoc;
    late MockDocumentReference mockBudgetDocRef;
    late MockCollectionReferenceExpenses mockExpensesCollection;
    late MockQuerySnapshot mockExpensesQuerySnapshot;
    late FirebaseBudgetRepository repository;

    const testUserId = 'test-user-id';

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockBudgetsCollection = MockCollectionReference();
      mockBudgetQuerySnapshot = MockQuerySnapshot();
      mockBudgetDoc = MockQueryDocumentSnapshot();
      mockBudgetDocRef = MockDocumentReference();
      mockExpensesCollection = MockCollectionReferenceExpenses();
      mockExpensesQuerySnapshot = MockQuerySnapshot();

      repository = FirebaseBudgetRepository(
        firestore: mockFirestore,
        userId: testUserId,
      );

      // Setup common mock responses
      when(
        () => mockFirestore.collection('budgets'),
      ).thenReturn(mockBudgetsCollection);
      when(() => mockBudgetDoc.reference).thenReturn(mockBudgetDocRef);
      when(
        () => mockBudgetDocRef.collection('expenses'),
      ).thenReturn(mockExpensesCollection);

      // Setup the where() method to return the same collection reference
      when(
        () => mockBudgetsCollection.where('userId', isEqualTo: testUserId),
      ).thenReturn(mockBudgetsCollection);
    });

    group('fetchExpenses', () {
      test('returns empty list when no budget exists for user', () async {
        // Arrange
        when(
          () => mockBudgetsCollection.get(),
        ).thenAnswer((_) async => mockBudgetQuerySnapshot);
        when(() => mockBudgetQuerySnapshot.docs).thenReturn([]);

        // Act
        final result = await repository.fetchExpenses();

        // Assert
        expect(result, isEmpty);
        verify(
          () => mockBudgetsCollection.where('userId', isEqualTo: testUserId),
        ).called(1);
        verify(() => mockBudgetsCollection.get()).called(1);
      });

      test('returns expenses when budget and expenses exist', () async {
        // Arrange
        final mockExpenseDoc1 = MockQueryDocumentSnapshot();
        final mockExpenseDoc2 = MockQueryDocumentSnapshot();

        final expenseData1 = {
          'name': 'Groceries',
          'amount': 50.0,
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
        };
        final expenseData2 = {
          'name': 'Transport',
          'amount': 25.0,
          'createdAt': Timestamp.fromDate(DateTime(2024, 1, 2)),
        };

        when(
          () => mockBudgetsCollection.get(),
        ).thenAnswer((_) async => mockBudgetQuerySnapshot);
        when(() => mockBudgetQuerySnapshot.docs).thenReturn([mockBudgetDoc]);
        when(
          () => mockExpensesCollection.get(),
        ).thenAnswer((_) async => mockExpensesQuerySnapshot);
        when(
          () => mockExpensesQuerySnapshot.docs,
        ).thenReturn([mockExpenseDoc1, mockExpenseDoc2]);
        when(() => mockExpenseDoc1.data()).thenReturn(expenseData1);
        when(() => mockExpenseDoc1.id).thenReturn('expense-1');
        when(() => mockExpenseDoc2.data()).thenReturn(expenseData2);
        when(() => mockExpenseDoc2.id).thenReturn('expense-2');

        // Act
        final result = await repository.fetchExpenses();

        // Assert
        expect(result, hasLength(2));
        expect(result[0].id, 'expense-1');
        expect(result[0].name, 'Groceries');
        expect(result[0].amount, 50.0);
        expect(result[0].createdAt, DateTime(2024, 1, 1));
        expect(result[1].id, 'expense-2');
        expect(result[1].name, 'Transport');
        expect(result[1].amount, 25.0);
        expect(result[1].createdAt, DateTime(2024, 1, 2));

        verify(
          () => mockBudgetsCollection.where('userId', isEqualTo: testUserId),
        ).called(1);
        verify(() => mockBudgetsCollection.get()).called(1);
        verify(() => mockExpensesCollection.get()).called(1);
      });

      test('throws exception when Firestore query fails', () async {
        // Arrange
        when(() => mockBudgetsCollection.get()).thenThrow(
          FirebaseException(plugin: 'firestore', message: 'Network error'),
        );

        // Act & Assert
        expect(
          () => repository.fetchExpenses(),
          throwsA(isA<FirebaseException>()),
        );
      });

      test('throws exception when expenses collection query fails', () async {
        // Arrange
        when(
          () => mockBudgetsCollection.get(),
        ).thenAnswer((_) async => mockBudgetQuerySnapshot);
        when(() => mockBudgetQuerySnapshot.docs).thenReturn([mockBudgetDoc]);
        when(() => mockExpensesCollection.get()).thenThrow(
          FirebaseException(plugin: 'firestore', message: 'Network error'),
        );

        // Act & Assert
        expect(
          () => repository.fetchExpenses(),
          throwsA(isA<FirebaseException>()),
        );
      });

      test(
        'throws exception when expense data has missing required fields',
        () async {
          // Arrange
          final mockExpenseDoc = MockQueryDocumentSnapshot();
          final expenseData = {
            'name': 'Partial Expense',
            // Missing amount and createdAt
          };

          when(
            () => mockBudgetsCollection.get(),
          ).thenAnswer((_) async => mockBudgetQuerySnapshot);
          when(() => mockBudgetQuerySnapshot.docs).thenReturn([mockBudgetDoc]);
          when(
            () => mockExpensesCollection.get(),
          ).thenAnswer((_) async => mockExpensesQuerySnapshot);
          when(
            () => mockExpensesQuerySnapshot.docs,
          ).thenReturn([mockExpenseDoc]);
          when(() => mockExpenseDoc.data()).thenReturn(expenseData);
          when(() => mockExpenseDoc.id).thenReturn('expense-1');

          // Act & Assert
          expect(
            () => repository.fetchExpenses(),
            throwsA(isA<ArgumentError>()),
          );
        },
      );
    });

    group('constructor', () {
      test('uses provided Firestore instance', () {
        // Arrange & Act
        final customRepository = FirebaseBudgetRepository(
          firestore: mockFirestore,
          userId: testUserId,
        );

        // Assert
        expect(customRepository, isA<FirebaseBudgetRepository>());
      });
    });
  });

  group('firebaseBudgetRepositoryProvider', () {
    test('provides FirebaseBudgetRepository instance', () {
      expect(
        firebaseBudgetRepositoryProvider,
        isA<Provider<BudgetRepository>>(),
      );
    });
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budget/features/home/data/budget_repository.dart';
import 'package:budget/features/home/domain/expense_model.dart';

class FirebaseBudgetRepository implements BudgetRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  FirebaseBudgetRepository({
    FirebaseFirestore? firestore,
    required String userId,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _userId = userId;

  @override
  Future<List<ExpenseModel>> fetchExpenses() async {
    try {
      final budgetQuerySnapshot = await _firestore
          .collection('budgets')
          .where('userId', isEqualTo: _userId)
          .get();
      if (budgetQuerySnapshot.docs.isEmpty) return [];

      final expensesQuerySnapshot = await budgetQuerySnapshot
          .docs.first.reference
          .collection('expenses')
          .get();

      final expenses = <ExpenseModel>[];
      for (final expenseDoc in expensesQuerySnapshot.docs) {
        final data = expenseDoc.data();
        final expense = ExpenseModel.fromMap(data, expenseDoc.id);
        expenses.add(expense);
      }

      return expenses;
    } catch (e) {
      print('Error fetching expenses from Firebase: $e');
      rethrow;
    }
  }
}

final firebaseBudgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  const userId = 'jlH0UrhFqKabFljFXz7wfy4Xk0u2';
  return FirebaseBudgetRepository(userId: userId);
});

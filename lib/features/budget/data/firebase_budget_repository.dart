import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budget/features/budget/data/budget_repository.dart';
import 'package:budget/features/budget/domain/expense_model.dart';
import 'package:budget/features/budget/domain/firebase_budget_model.dart';

class FirebaseBudgetRepository implements BudgetRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  FirebaseBudgetRepository({
    FirebaseFirestore? firestore,
    required String userId,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _userId = userId;

  @override
  Future<bool> isBudgetCreated() async {
    final budgetQuerySnapshot = await _firestore
        .collection('budgets')
        .where('userId', isEqualTo: _userId)
        .get();
    return budgetQuerySnapshot.docs.isNotEmpty;
  }

  @override
  Future<void> createBudget() async {
    try {
      final budgetModel = FirebaseBudgetModel(userId: _userId);
      await _firestore.collection('budgets').add(budgetModel.toFirebaseMap());
    } catch (e) {
      print('Error creating budget in Firebase: $e');
      rethrow;
    }
  }

  @override
  Future<List<ExpenseModel>> fetchExpenses() async {
    try {
      final budgetQuerySnapshot = await _firestore
          .collection('budgets')
          .where('userId', isEqualTo: _userId)
          .get();
      if (budgetQuerySnapshot.docs.isEmpty) return [];

      final expensesQuerySnapshot = await budgetQuerySnapshot
          .docs
          .first
          .reference
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

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      final budgetQuerySnapshot = await _firestore
          .collection('budgets')
          .where('userId', isEqualTo: _userId)
          .get();

      if (budgetQuerySnapshot.docs.isEmpty) {
        throw Exception('Budget not found for user');
      }

      final budgetDoc = budgetQuerySnapshot.docs.first;

      await budgetDoc.reference
          .collection('expenses')
          .add(expense.toFirebaseMap());
    } catch (e) {
      print('Error adding expense to Firebase: $e');
      rethrow;
    }
  }
}

final firebaseBudgetRepositoryProvider =
    Provider.family<BudgetRepository, String>((ref, userId) {
  return FirebaseBudgetRepository(userId: userId);
});

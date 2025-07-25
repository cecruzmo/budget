import 'package:budget/features/budget/data/firebase_budget_repository.dart';
import 'package:budget/features/budget/domain/expense_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BudgetRepository {
  Future<bool> isBudgetCreated();
  Future<void> createBudget();
  Future<List<ExpenseModel>> fetchExpenses();
  Future<void> addExpense(ExpenseModel expense);
}

final budgetRepositoryProvider = Provider.family<BudgetRepository, String>((
  ref,
  userId,
) {
  return ref.watch(firebaseBudgetRepositoryProvider(userId));
});

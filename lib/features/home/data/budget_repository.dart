import 'package:budget/features/home/data/firebase_budget_repository.dart';
import 'package:budget/features/home/domain/expense_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BudgetRepository {
  Future<List<ExpenseModel>> fetchExpenses();
}

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return ref.watch(firebaseBudgetRepositoryProvider);
});

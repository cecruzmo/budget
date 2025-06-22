import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget/features/home/data/budget_repository.dart';
import 'package:budget/features/home/domain/expense_model.dart';

class BudgetService {
  final BudgetRepository _budgetRepository;

  BudgetService(this._budgetRepository);

  Future<List<ExpenseModel>> fetchExpenses() async =>
      await _budgetRepository.fetchExpenses();
}

final budgetServiceProvider = Provider<BudgetService>((ref) {
  final budgetRepository = ref.watch(budgetRepositoryProvider);
  return BudgetService(budgetRepository);
});

import 'package:budget/features/user/application/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget/features/budget/data/budget_repository.dart';
import 'package:budget/features/budget/domain/expense_model.dart';

class BudgetService {
  final BudgetRepository _budgetRepository;

  BudgetService(this._budgetRepository);

  Future<bool> isBudgetCreated() async =>
      await _budgetRepository.isBudgetCreated();

  Future<void> createBudget() async => await _budgetRepository.createBudget();
  
  Future<List<ExpenseModel>> fetchExpenses() async =>
      await _budgetRepository.fetchExpenses();
}

final budgetServiceProvider = Provider<BudgetService>((ref) {
  final user = ref.watch(userServiceProvider).getCurrentUser();
  if (user == null) throw Exception('No user logged in');
  final budgetRepository = ref.watch(budgetRepositoryProvider(user.id));
  return BudgetService(budgetRepository);
});

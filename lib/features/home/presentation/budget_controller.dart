import 'package:budget/features/home/application/budget_service.dart';
import 'package:budget/features/home/domain/expense_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetController extends StateNotifier<AsyncValue<List<ExpenseModel>>> {
  final BudgetService _budgetService;

  BudgetController(this._budgetService) : super(const AsyncValue.loading());

  Future<void> fetchExpenses() async =>
      state = await AsyncValue.guard(() => _budgetService.fetchExpenses());
}

final budgetControllerProvider =
    StateNotifierProvider<BudgetController, AsyncValue<List<ExpenseModel>>>((
      ref,
    ) {
  final budgetService = ref.watch(budgetServiceProvider);
  return BudgetController(budgetService);
});

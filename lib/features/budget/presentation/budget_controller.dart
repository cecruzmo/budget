import 'package:budget/features/budget/application/budget_service.dart';
import 'package:budget/features/budget/domain/budget_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetController extends StateNotifier<AsyncValue<BudgetModel>> {
  final BudgetService _budgetService;

  BudgetController(this._budgetService) : super(const AsyncValue.loading());

  Future<void> fetchExpenses() async {
    state = await AsyncValue.guard(() async {
      final expenses = await _budgetService.fetchExpenses();
      return BudgetModel(expenses: expenses);
    });
  }
}

final budgetControllerProvider =
    StateNotifierProvider<BudgetController, AsyncValue<BudgetModel>>((
      ref,
    ) {
      final budgetService = ref.watch(budgetServiceProvider);
      return BudgetController(budgetService);
    });

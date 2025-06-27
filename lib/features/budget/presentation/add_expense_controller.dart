import 'package:budget/features/budget/application/budget_service.dart';
import 'package:budget/features/budget/domain/expense_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddExpenseController extends StateNotifier<AsyncValue<void>> {
  final BudgetService _budgetService;

  AddExpenseController(this._budgetService)
    : super(const AsyncValue.data(null));

  Future<void> addExpense(String name, double amount) async {
    state = const AsyncValue.loading();
    final expense = ExpenseModel(
      id: '',
      name: name,
      amount: amount,
      createdAt: DateTime.now(),
    );
    state = await AsyncValue.guard(() => _budgetService.addExpense(expense));
  }
}

final addExpenseControllerProvider =
    StateNotifierProvider<AddExpenseController, AsyncValue<void>>((ref) {
      final budgetService = ref.watch(budgetServiceProvider);
      return AddExpenseController(budgetService);
    });

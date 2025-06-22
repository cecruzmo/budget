import 'package:budget/features/budget/domain/expense_model.dart';

class BudgetModel {
  final double totalExpense;
  final List<ExpenseModel> expenses;

  BudgetModel({required this.expenses})
    : totalExpense = expenses.fold(0.0, (sum, expense) => sum + expense.amount);

  BudgetModel copyWith({List<ExpenseModel>? expenses}) =>
      BudgetModel(expenses: expenses ?? this.expenses);
}

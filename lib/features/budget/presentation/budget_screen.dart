import 'package:budget/common/presentation/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budget/features/budget/presentation/budget_controller.dart';
import 'package:budget/common/utils/money_utils.dart';
import 'package:budget/features/budget/presentation/expense_item.dart';
import 'package:budget/common/utils/colors.dart';
import 'package:budget/features/budget/presentation/add_expense_item.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  bool _showAddExpenseItem = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(budgetControllerProvider.notifier).isBudgetCreated().then((
        isBudgetCreated,
      ) async {
        if (!isBudgetCreated) {
          await ref.read(budgetControllerProvider.notifier).createBudget();
        }
      });
      ref.read(budgetControllerProvider.notifier).fetchExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_total(context), _expenses(context)],
          ),
        ),
      ),
      floatingActionButton: _showAddExpenseItem
          ? null
          : FloatingActionButton(
              onPressed: () => setState(() => _showAddExpenseItem = true),
              backgroundColor: AppColors.gunmetal,
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget _total(BuildContext context) {
    final budgetAsync = ref.watch(budgetControllerProvider);
    return budgetAsync.when(
      data: (budgetModel) => Text(
        MoneyUtils.formatMoney(budgetModel.totalExpense),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Error: $error',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ),
    );
  }

  Widget _expenses(BuildContext context) {
    final budgetAsync = ref.watch(budgetControllerProvider);
    return budgetAsync.when(
      data: (budgetModel) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'EXPENSES'),
          if (_showAddExpenseItem) const AddExpenseItem(),
          ...budgetModel.expenses.map(
            (expense) => ExpenseItem(expense: expense),
          ),
        ],
      ),
      loading: () => const SizedBox(),
      error: (error, stackTrace) => const SizedBox(),
    );
  }
}

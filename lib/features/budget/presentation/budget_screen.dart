import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budget/features/budget/presentation/budget_controller.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
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
        child: Column(
          children: [_totalExpenseCard(context), _expensesList(context)],
        ),
      ),
    );
  }

  Widget _totalExpenseCard(BuildContext context) {
    final budgetAsync = ref.watch(budgetControllerProvider);
    return budgetAsync.when(
      data: (budgetModel) => Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Total Expenses',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '\$${budgetModel.totalExpense.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
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

  Widget _expensesList(BuildContext context) {
    final budgetAsync = ref.watch(budgetControllerProvider);
    return budgetAsync.when(
      data: (budgetModel) => Expanded(
        child: budgetModel.expenses.isEmpty
            ? const Center(child: Text('No expenses found'))
            : ListView.builder(
                itemCount: budgetModel.expenses.length,
                itemBuilder: (context, index) {
                  final expense = budgetModel.expenses[index];
                  return ListTile(
                    title: Text(expense.name),
                    subtitle: Text(expense.createdAt.toString()),
                    trailing: Text(
                      '\$${expense.amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                },
              ),
      ),
      loading: () =>
          const Expanded(child: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Expanded(
        child: Center(
          child: Text(
            'Error: $error',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}

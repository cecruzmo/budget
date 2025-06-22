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
      ref.read(budgetControllerProvider.notifier).fetchExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Column(children: [_expensesList(context)])),
    );
  }

  Widget _expensesList(BuildContext context) {
    final expensesAsync = ref.watch(budgetControllerProvider);
    return expensesAsync.when(
      data: (expenses) => Expanded(
        child: expenses.isEmpty
            ? const Center(child: Text('No expenses found'))
            : ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          'Error: $error',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

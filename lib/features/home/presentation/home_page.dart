import 'package:budget/features/home/presentation/total_expenses_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(child: Column(children: [_totalExpenses(context, ref)])),
    );
  }

  Widget _totalExpenses(BuildContext context, WidgetRef ref) {
    final totalExpenses = ref.watch(totalExpensesControllerProvider);
    return totalExpenses.when(
      data: (total) => Center(
        child: Text(total, style: Theme.of(context).textTheme.displayLarge),
      ),
      loading: () => const SizedBox(),
      error: (error, stackTrace) => Center(
        child: Text('⚠️', style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}

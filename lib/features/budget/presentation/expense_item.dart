import 'package:flutter/material.dart' hide DateUtils;

import 'package:budget/common/utils/colors.dart';
import 'package:budget/common/utils/money_utils.dart';
import 'package:budget/common/utils/date_utils.dart';
import 'package:budget/features/budget/domain/expense_model.dart';

class ExpenseItem extends StatelessWidget {
  final ExpenseModel expense;

  const ExpenseItem({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                DateUtils.formatDate(expense.createdAt),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gunmetal.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                expense.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              MoneyUtils.formatMoney(expense.amount),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.gunmetal.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

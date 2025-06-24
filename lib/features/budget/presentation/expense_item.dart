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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              DateUtils.formatDate(expense.createdAt),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.gunmetal.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              expense.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.gunmetal,
              ),
            ),
          ),
          Text(
            MoneyUtils.formatMoney(expense.amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.gunmetal.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

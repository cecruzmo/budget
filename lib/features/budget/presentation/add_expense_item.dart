import 'package:flutter/material.dart' hide DateUtils;

import 'package:budget/common/utils/colors.dart';
import 'package:budget/common/utils/date_utils.dart';

class AddExpenseItem extends StatelessWidget {
  const AddExpenseItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 12.0,
          right: 6.0,
          top: 2.0,
          bottom: 2.0,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                DateUtils.formatDate(DateTime.now()),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gunmetal.withValues(alpha: 0.6),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Type description',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.gunmetal.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 100,
              child: TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: '0.00',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.gunmetal.withValues(alpha: 0.5),
                  ),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

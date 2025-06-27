import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budget/common/utils/colors.dart';
import 'package:budget/common/utils/date_utils.dart';
import 'package:budget/features/budget/presentation/add_expense_controller.dart';

class AddExpenseItem extends ConsumerStatefulWidget {
  final VoidCallback onExpenseAdded;

  const AddExpenseItem({super.key, required this.onExpenseAdded});

  @override
  ConsumerState<AddExpenseItem> createState() => _AddExpenseItemState();
}

class _AddExpenseItemState extends ConsumerState<AddExpenseItem> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _nameFocusNode.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      _nameFocusNode.requestFocus();
      return;
    }

    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      _amountFocusNode.requestFocus();
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount greater than 0'),
        ),
      );
      _amountFocusNode.requestFocus();
      return;
    }

    final controller = ref.read(addExpenseControllerProvider.notifier);
    controller.addExpense(name, amount).then((_) {
      final state = ref.read(addExpenseControllerProvider);
      state.when(
        data: (_) {
          _nameController.clear();
          _amountController.clear();
          widget.onExpenseAdded();
        },
        loading: () {},
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add expense: ${error.toString()}'),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final addExpenseState = ref.watch(addExpenseControllerProvider);
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
                controller: _nameController,
                focusNode: _nameFocusNode,
                textCapitalization: TextCapitalization.words,
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
                onSubmitted: (_) => _amountFocusNode.requestFocus(),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 100,
              child: TextField(
                controller: _amountController,
                focusNode: _amountFocusNode,
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
                onSubmitted: (_) => _handleSubmit(),
              ),
            ),
            if (addExpenseState.isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }
}

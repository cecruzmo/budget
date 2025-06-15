import 'package:flutter_riverpod/flutter_riverpod.dart';

class TotalExpensesController extends StateNotifier<AsyncValue<String>> {
  TotalExpensesController() : super(const AsyncValue.loading());

  void fetchTotalExpenses() async {
    state = const AsyncValue.loading();
  }
}

final totalExpensesControllerProvider =
    StateNotifierProvider<TotalExpensesController, AsyncValue<String>>((ref) {
      return TotalExpensesController();
    });

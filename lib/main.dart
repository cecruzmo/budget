import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budget/common/utils/colors.dart';
import 'package:budget/features/budget/presentation/budget_screen.dart';
import 'package:budget/features/user/presentation/user_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(userControllerProvider.notifier).initUser();
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: AppColors.ghostWhite),
      home: const BudgetScreen(),
    );
  }
}

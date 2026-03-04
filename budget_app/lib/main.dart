import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/budget_provider.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Creamos providers, inicializamos lo que toca, y luego corremos la app
  final budgetProvider = BudgetProvider();
  await budgetProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider<BudgetProvider>.value(value: budgetProvider),
      ],
      child: const MyApp(),
    ),
  );
}
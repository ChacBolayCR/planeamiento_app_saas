import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/budget_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BudgetProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'providers/auth_provider.dart';
import 'providers/budget_provider.dart';

import 'screens/onboarding/onboarding_gate.dart';
import 'screens/dashboard/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        /// AUTH
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        /// BUDGET
        ChangeNotifierProvider(
          create: (_) {
            final provider = BudgetProvider();
            provider.init(); // IMPORTANTE
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kiki Finance',

        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
        ),

        routes: {
          '/dashboard': (_) => const DashboardScreen(),
        },

        home: const OnboardingGate(),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'providers/auth_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/category_catalog_provider.dart';
import 'providers/commitments_provider.dart';
import 'providers/financial_profile_provider.dart';

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

        /// CATEGORY CATALOG
        ChangeNotifierProvider(
          create: (_) {
            final provider = CategoryCatalogProvider();
            provider.init();
            return provider;
          },
        ),

        /// COMMITMENTS
        ChangeNotifierProvider(
          create: (_) {
            final provider = CommitmentsProvider();
            provider.init();
            return provider;
          },
        ),

        /// FINANCIAL PROFILE
        ChangeNotifierProvider(
          create: (_) {
            final provider = FinancialProfileProvider();
            provider.init();
            return provider;
          },
        ),

        /// BUDGET
        ChangeNotifierProvider(
          create: (_) {
            final provider = BudgetProvider();
            provider.init();
            provider.initPurchases();
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

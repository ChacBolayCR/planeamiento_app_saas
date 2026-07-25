import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/financial_profile_provider.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_screen.dart';
import 'onboarding_screen.dart';

class OnboardingGate extends StatelessWidget {
  const OnboardingGate({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<FinancialProfileProvider>();

    if (!profile.isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!profile.onboardingCompleted) {
      return const OnboardingScreen();
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return const DashboardScreen();
    }

    return const LoginScreen();
  }
}

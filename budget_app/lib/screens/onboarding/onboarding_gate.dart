import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/login_screen.dart';
import '../dashboard/dashboard_screen.dart';
import 'onboarding_screen.dart';

class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key});

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {

  bool _loading = true;
  bool _seenOnboarding = false;
  bool _isLogged = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {

    final prefs = await SharedPreferences.getInstance();

    final seen = prefs.getBool('onboarding_done') ?? false;
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      _seenOnboarding = seen;
      _isLogged = user != null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_seenOnboarding) {
      return const OnboardingScreen();
    }

    if (_isLogged) {
      return const DashboardScreen();
    }

    return const LoginScreen();
  }
}
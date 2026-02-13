import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';
import '../../navigation/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final String selectedImage;

  final List<String> kikiImages = [
    'assets/images/kiki/kiki_idle.png',
    'assets/images/kiki/kiki_play.png',
    'assets/images/kiki/kiki_happy.png',
  ];

  @override
  void initState() {
    super.initState();

    selectedImage = kikiImages[Random().nextInt(kikiImages.length)];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _boot();
    });
  }

  Future<void> _boot() async {
    // ✅ Inicializa prefs / mes / cache de gastos
    await context.read<BudgetProvider>().init();

    // ⏳ duración del splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(selectedImage, width: 180),
            const SizedBox(height: 24),
            Text(
              'Kiki Finance',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'La libertad empieza con educación financiera 💳',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

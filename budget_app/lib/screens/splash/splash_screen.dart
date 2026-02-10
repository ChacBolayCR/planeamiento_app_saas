import 'dart:math';
import 'package:flutter/material.dart';

import '../../navigation/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late String selectedImage;

  final List<String> kikiImages = [
    'assets/images/kiki/kiki_idle.png',
    'assets/images/kiki/kiki_play.png',
    'assets/images/kiki/kiki_main.png',
    'assets/images/kiki/kiki_happy.png',
  ];

  @override
  void initState() {
    super.initState();

    selectedImage = kikiImages[Random().nextInt(kikiImages.length)];

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    });
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
            Text('Kiki Finance', style: Theme.of(context).textTheme.headlineSmall),
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

import 'dart:async';
import 'package:flutter/material.dart';
import '../home/home_screen.dart';

import '../../widgets/kiki_avatar.dart';
import '../dashboard/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (_) => const HomeScreen(),
            ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🐾 Kiki
              const KikiAvatar(state: KikiState.idle),

              const SizedBox(height: 32),

              // 💬 Eslogan
              const Text(
                'La libertad empieza con educación financiera 💳',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              // ⏳ Loader
              CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white.withOpacity(0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

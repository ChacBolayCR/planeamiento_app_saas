import 'package:flutter/material.dart';
import '../splash/splash_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),

            /// 🐱 Logo Kiki
            Center(
              child: Image.asset(
                'assets/images/kiki/kiki_play.png',
                height: 140,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Kiki Finance',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Controla tus gastos en 2 minutos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                );
              },
              child: const Text('Entrar'),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

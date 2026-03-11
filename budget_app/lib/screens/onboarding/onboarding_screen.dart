import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  Widget _pageItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(
            icon,
            size: 100,
            color: Colors.blue,
          ),

          const SizedBox(height: 40),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (i) => setState(() => _page = i),
        children: [

          _pageItem(
            icon: Icons.pets,
            title: 'Bienvenido a Kiki',
            subtitle: 'Controla tus gastos\nsin hojas de Excel',
          ),

          _pageItem(
            icon: Icons.bar_chart,
            title: 'Entiende tu dinero',
            subtitle: 'Kiki te muestra en qué\nestás gastando realmente',
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: _page == 1
              ? _finish
              : () => _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
          child: Text(_page == 1 ? 'Empezar' : 'Siguiente'),
        ),
      ),
    );
  }
}
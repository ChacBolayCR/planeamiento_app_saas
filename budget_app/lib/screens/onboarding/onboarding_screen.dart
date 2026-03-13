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

  Widget _kikiPage({
    required String message,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          /// Kiki
          AnimatedScale(
            duration: const Duration(milliseconds: 300),
            scale: _page == 0 ? 1 : 1.05,
            child: Image.asset(
              'assets/images/kiki/kiki_idle_main_v2.png',
              height: 160,
            ),
          ),

          const SizedBox(height: 40),

          /// burbuja
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(.05),
                )
              ],
            ),
            child: Column(
              children: [

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      body: PageView(
        controller: _controller,
        onPageChanged: (i) => setState(() => _page = i),
        children: [

          _kikiPage(
            message: "Hola, soy Kiki 🐾",
            subtitle: "Te ayudaré a controlar tus gastos\nsin hojas de Excel.",
          ),

          _kikiPage(
            message: "Descubre en qué gastas",
            subtitle: "Kiki analiza tus gastos y te muestra\ncómo mejorar tus finanzas.",
          ),

          _kikiPage(
            message: "Kiki también puede ayudarte más 🧠",
            subtitle: "Con Kiki Pro podrás ver patrones de gasto, metas y análisis más profundos.",
          ),

          _kikiPage(
            message: "Empieza hoy mismo",
            subtitle: "Registra tus gastos en segundos\ny deja que Kiki haga el resto.",
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == index ? 12 : 8,
                    height: _page == index ? 12 : 8,
                    decoration: BoxDecoration(
                      color: _page == index
                          ? Colors.blue
                          : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// botón
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _page == 3
                      ? _finish
                      : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                  child: Text(
                    _page == 3 ? "Empezar" : "Siguiente",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
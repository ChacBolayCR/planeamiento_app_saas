import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../splash/splash_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  Future<void> _goToSplash() async {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
  }

  Future<void> _login() async {
    final email = _email.text.trim();
    final pass = _pass.text;

    if (email.isEmpty || !email.contains('@') || pass.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa tu correo y contraseña'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    await context.read<AuthProvider>().login(email, pass);
    setState(() => _loading = false);

    await _goToSplash();
  }

  Future<void> _guest() async {
    setState(() => _loading = true);
    await context.read<AuthProvider>().loginAsGuest();
    setState(() => _loading = false);

    await _goToSplash();
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // 🐱 Logo Kiki
              Center(
                child: Image.asset(
                  'assets/images/kiki/kiki_idle_main_v2.png',
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

              const SizedBox(height: 18),

              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _pass,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Entrar'),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: _loading ? null : _guest,
                child: const Text(
                  'Entrar sin cuenta',
                  style: TextStyle(color: Colors.black54),
                ),
              ),

              const Spacer(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

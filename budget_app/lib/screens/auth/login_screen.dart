import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();

  bool _isRegisterMode = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final pass = _pass.text.trim();
    final auth = context.read<AuthProvider>();

    if (email.isEmpty || !email.contains('@')) {
      _showMessage('Ingresa un correo válido');
      return;
    }

    if (pass.length < 6) {
      _showMessage('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    try {
      if (_isRegisterMode) {
        await auth.register(email, pass);
        _showMessage('Cuenta creada ✅ Revisa tu correo para verificar tu cuenta.');
      } else {
        await auth.login(email, pass);
      }
    } catch (e) {
      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _guest() async {
    try {
      await context.read<AuthProvider>().loginAsGuest();
    } catch (_) {
      _showMessage('No se pudo entrar como invitado');
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loading = auth.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              Center(
                child: Image.asset(
                  'assets/images/kiki/kiki_idle_main_v2.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                _isRegisterMode ? 'Crea tu cuenta' : 'Bienvenido a Kiki Budget',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                _isRegisterMode
                    ? 'Registra tu cuenta para guardar tu progreso.'
                    : 'Controla tus gastos con Kiki 🐾',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 24),

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
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isRegisterMode ? 'Crear cuenta' : 'Entrar'),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: loading ? null : () {
                  setState(() => _isRegisterMode = !_isRegisterMode);
                },
                child: Text(
                  _isRegisterMode
                      ? 'Ya tengo cuenta'
                      : 'Crear cuenta',
                ),
              ),

              TextButton(
                onPressed: loading ? null : _guest,
                child: const Text(
                  'Entrar sin cuenta',
                  style: TextStyle(color: Colors.black54),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design_system/components/kiki_button.dart';
import '../../design_system/components/kiki_card.dart';
import '../../design_system/kiki_colors.dart';
import '../../design_system/kiki_spacing.dart';
import '../../providers/auth_provider.dart';
import '../../utils/kiki_avatar_assets.dart';
import '../onboarding/onboarding_gate.dart';

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

        if (!mounted) return;

        _showMessage('Cuenta creada. Revisa tu correo.');

        setState(() {
          _isRegisterMode = false;
        });
      } else {
        await auth.login(email, pass);

        if (!mounted) return;

        _goToEntryGate();
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');

      _showMessage(msg);
    }
  }

  Future<void> _guest() async {
    try {
      await context.read<AuthProvider>().loginAsGuest();

      if (!mounted) return;

      _goToEntryGate();
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');

      _showMessage(msg);
    }
  }

  void _goToEntryGate() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingGate()),
      (_) => false,
    );
  }

  void _showMessage(String text) {
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: KikiColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: KikiSpacing.md),
              Center(
                child: Image.asset(
                  KikiAvatarAssets.wave,
                  height: 190,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
              const SizedBox(height: KikiSpacing.xl),
              Text(
                _isRegisterMode
                    ? 'Crea tu cuenta'
                    : 'Bienvenido a Kiki Finance',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: KikiColors.textPrimary,
                ),
              ),
              const SizedBox(height: KikiSpacing.sm),
              Text(
                _isRegisterMode
                    ? 'Registra tu cuenta para guardar tu progreso.'
                    : 'Controla tus gastos con Kiki.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: KikiColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: KikiSpacing.xl),
              KikiCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Correo'),
                    ),
                    const SizedBox(height: KikiSpacing.md),
                    TextField(
                      controller: _pass,
                      obscureText: true,
                      decoration:
                          const InputDecoration(labelText: 'Contraseña'),
                    ),
                    const SizedBox(height: KikiSpacing.lg),
                    KikiButton(
                      label: _isRegisterMode ? 'Crear cuenta' : 'Entrar',
                      onPressed: loading ? null : _submit,
                      loading: loading,
                    ),
                    const SizedBox(height: KikiSpacing.sm),
                    TextButton(
                      onPressed: loading
                          ? null
                          : () {
                              setState(
                                  () => _isRegisterMode = !_isRegisterMode);
                            },
                      child: Text(
                        _isRegisterMode ? 'Ya tengo cuenta' : 'Crear cuenta',
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: loading ? null : _guest,
                child: Text(
                  'Entrar sin cuenta',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

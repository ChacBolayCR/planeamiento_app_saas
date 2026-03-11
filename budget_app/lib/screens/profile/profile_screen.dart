import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../providers/budget_provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _budgetController;

  String _selectedCurrency = 'CRC';

  final List<Map<String, String>> _currencies = const [
    {'code': 'USD', 'label': 'USD - Dólar'},
    {'code': 'CRC', 'label': 'CRC - Colón'},
    {'code': 'EUR', 'label': 'EUR - Euro'},
    {'code': 'MXN', 'label': 'MXN - Peso MX'},
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _budgetController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final budget = context.read<BudgetProvider>();
      final user = FirebaseAuth.instance.currentUser;

      _nameController.text = user?.displayName ?? '';
      _budgetController.text = budget.monthlyBudget.toStringAsFixed(0);
      _selectedCurrency = budget.currencyCode;

      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final budget = context.read<BudgetProvider>();
    final auth = context.read<app_auth.AuthProvider>();

    final parsedBudget = double.tryParse(_budgetController.text.trim());

    if (parsedBudget == null || parsedBudget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un presupuesto válido'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      budget.setMonthlyBudget(parsedBudget);
      budget.setCurrency(_selectedCurrency);

      final newName = _nameController.text.trim();
      if (newName.isNotEmpty) {
        await auth.updateDisplayName(newName);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado ✅'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _logout() async {
    await context.read<app_auth.AuthProvider>().logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final auth = context.watch<app_auth.AuthProvider>();
    final user = FirebaseAuth.instance.currentUser;

    final name = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!
        : 'Usuario';

    final email = user?.email ?? 'Invitado';

    final isPro = budget.isPro;
    final trialActive = budget.isTrialActive;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// HEADER
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.12),
                        child: const Icon(
                          Icons.person,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// ESTADO
              Card(
                elevation: 0,
                child: ListTile(
                  leading: const Icon(Icons.workspace_premium_rounded),
                  title: const Text(
                    'Estado de la cuenta',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    trialActive
                        ? 'Pro Trial activo (${budget.trialDaysLeft} días restantes)'
                        : isPro
                            ? 'Kiki Pro activo'
                            : 'Versión Free',
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// FORM
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Presupuesto mensual',
                          prefixText: '${budget.currencySymbol} ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCurrency,
                        decoration: InputDecoration(
                          labelText: 'Moneda',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _currencies
                            .map(
                              (c) => DropdownMenuItem(
                                value: c['code'],
                                child: Text(c['label']!),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCurrency = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// RESUMEN RÁPIDO
              Card(
                elevation: 0,
                child: ListTile(
                  leading: const Icon(Icons.account_balance_wallet),
                  title: const Text(
                    'Presupuesto actual',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${budget.currencySymbol}${budget.monthlyBudget.toStringAsFixed(2)}',
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Card(
                elevation: 0,
                child: ListTile(
                  leading: const Icon(Icons.currency_exchange),
                  title: const Text(
                    'Moneda activa',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(budget.currencyCode),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _saveProfile,
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar cambios'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: auth.isLoading ? null : _logout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
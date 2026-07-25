import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/budget_provider.dart';
import '../../providers/financial_profile_provider.dart';
import '../../services/category_catalog.dart';
import '../auth/login_screen.dart';
import '../onboarding/onboarding_screen.dart';

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
          content: Text('Perfil actualizado'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
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
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _resetExperience() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restablecer personalización'),
        content: const Text(
          'Esto no borrará tus gastos, compromisos ni presupuesto.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await context.read<FinancialProfileProvider>().resetOnboarding();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Personalización restablecida'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final auth = context.watch<app_auth.AuthProvider>();
    final financialProfile = context.watch<FinancialProfileProvider>();
    final profile = financialProfile.profile;
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileHeader(name: name, email: email),
              const SizedBox(height: 16),
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
              _SettingsCard(
                nameController: _nameController,
                budgetController: _budgetController,
                currencies: _currencies,
                selectedCurrency: _selectedCurrency,
                currencySymbol: budget.currencySymbol,
                onCurrencyChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCurrency = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              _ExperienceCard(
                incomeLabels: profile.selectedIncomeTypes
                    .map(CategoryCatalog.labelForIncome)
                    .toList(),
                expenseLabels: profile.selectedExpenseCategories
                    .map(CategoryCatalog.labelForExpenseProfile)
                    .toList(),
                goalLabel: CategoryCatalog.labelForGoal(profile.primaryGoal),
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OnboardingScreen(editMode: true),
                    ),
                  );
                },
                onReset: _resetExperience,
              ),
              const SizedBox(height: 16),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileHeader({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
              child: const Icon(Icons.person, size: 32),
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController budgetController;
  final List<Map<String, String>> currencies;
  final String selectedCurrency;
  final String currencySymbol;
  final ValueChanged<String?> onCurrencyChanged;

  const _SettingsCard({
    required this.nameController,
    required this.budgetController,
    required this.currencies,
    required this.selectedCurrency,
    required this.currencySymbol,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Presupuesto mensual',
                prefixText: '$currencySymbol ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCurrency,
              decoration: InputDecoration(
                labelText: 'Moneda',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: currencies
                  .map(
                    (currency) => DropdownMenuItem(
                      value: currency['code'],
                      child: Text(currency['label']!),
                    ),
                  )
                  .toList(),
              onChanged: onCurrencyChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final List<String> incomeLabels;
  final List<String> expenseLabels;
  final String goalLabel;
  final VoidCallback onEdit;
  final VoidCallback onReset;

  const _ExperienceCard({
    required this.incomeLabels,
    required this.expenseLabels,
    required this.goalLabel,
    required this.onEdit,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tu experiencia',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            _ExperienceLine(
              label: 'Ingresos',
              value: incomeLabels.isEmpty
                  ? 'Sin personalizar'
                  : incomeLabels.join(', '),
            ),
            _ExperienceLine(
              label: 'Categorías principales',
              value: expenseLabels.isEmpty
                  ? 'Todas disponibles'
                  : expenseLabels.join(', '),
            ),
            _ExperienceLine(label: 'Objetivo', value: goalLabel),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.tune),
                  label: const Text('Editar preferencias'),
                ),
                TextButton(
                  onPressed: onReset,
                  child: const Text('Restablecer personalización'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperienceLine extends StatelessWidget {
  final String label;
  final String value;

  const _ExperienceLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(value),
        ],
      ),
    );
  }
}

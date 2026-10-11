import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design_system/components/kiki_avatar_frame.dart';
import '../../design_system/components/kiki_button.dart';
import '../../design_system/components/kiki_card.dart';
import '../../design_system/kiki_colors.dart';
import '../../design_system/kiki_spacing.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/budget_provider.dart';
import '../../providers/financial_profile_provider.dart';
import '../../services/category_catalog.dart';
import '../auth/login_screen.dart';
import '../../widgets/companion_selector_sheet.dart';
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
    {'code': 'USD', 'label': 'USD - D\u00f3lar'},
    {'code': 'CRC', 'label': 'CRC - Col\u00f3n'},
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
        const SnackBar(content: Text('Ingresa un presupuesto v\u00e1lido')),
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
        const SnackBar(content: Text('Perfil actualizado')),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
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
        title: const Text('Restablecer personalizaci\u00f3n'),
        content: const Text(
          'Esto no borrar\u00e1 tus gastos, compromisos ni presupuesto.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          KikiButton(
            label: 'Restablecer',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await context.read<FinancialProfileProvider>().resetPersonalization();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Personalizaci\u00f3n restablecida')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final auth = context.watch<app_auth.AuthProvider>();
    final profile = context.watch<FinancialProfileProvider>().profile;
    final user = FirebaseAuth.instance.currentUser;

    final name = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!
        : 'Usuario';
    final email = user?.email ?? 'Invitado';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(KikiSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileHeader(name: name, email: email),
              const SizedBox(height: KikiSpacing.lg),
              _CompanionProfileCard(
                selectedAvatarId: profile.selectedAvatarId,
                onChange: _openCompanionSelector,
              ),
              const SizedBox(height: KikiSpacing.lg),
              _AccountStatusCard(budget: budget),
              const SizedBox(height: KikiSpacing.lg),
              _SettingsCard(
                nameController: _nameController,
                budgetController: _budgetController,
                currencies: _currencies,
                selectedCurrency: _selectedCurrency,
                currencySymbol: budget.currencySymbol,
                onCurrencyChanged: (value) {
                  if (value != null) setState(() => _selectedCurrency = value);
                },
              ),
              const SizedBox(height: KikiSpacing.lg),
              _ExperienceCard(
                incomeLabels: profile.selectedIncomeTypes
                    .map(CategoryCatalog.labelForIncome)
                    .toList(),
                expenseLabels: profile.selectedExpenseCategories
                    .map(CategoryCatalog.labelForExpenseProfile)
                    .toList(),
                goalLabels: profile.selectedGoals
                    .map(CategoryCatalog.labelForGoal)
                    .toList(),
                primaryGoalLabel:
                    CategoryCatalog.labelForGoal(profile.primaryGoal),
                onEdit: _openPreferences,
                onReset: _resetExperience,
              ),
              const SizedBox(height: KikiSpacing.lg),
              _BudgetSummaryCard(budget: budget),
              const SizedBox(height: KikiSpacing.xl),
              KikiButton(
                label: 'Guardar cambios',
                onPressed: auth.isLoading ? null : _saveProfile,
                loading: auth.isLoading,
              ),
              const SizedBox(height: KikiSpacing.md),
              KikiButton(
                label: 'Cerrar sesi\u00f3n',
                icon: Icons.logout,
                variant: KikiButtonVariant.destructive,
                onPressed: auth.isLoading ? null : _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCompanionSelector() async {
    final provider = context.read<FinancialProfileProvider>();
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CompanionSelectorSheet(
        selectedAvatarId: provider.profile.selectedAvatarId,
      ),
    );

    if (selected == null || !mounted) return;
    await provider.updateSelectedAvatar(selected);
  }

  void _openPreferences() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen(editMode: true)),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileHeader({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return KikiCard(
      child: Row(
        children: [
          KikiAvatarFrame(
            fallbackIcon: Icons.person,
            size: 68,
            semanticLabel: 'Perfil de usuario',
          ),
          const SizedBox(width: KikiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.titleLarge),
                const SizedBox(height: KikiSpacing.xs),
                Text(
                  email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanionProfileCard extends StatelessWidget {
  final String selectedAvatarId;
  final VoidCallback onChange;

  const _CompanionProfileCard({
    required this.selectedAvatarId,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final option = CategoryCatalog.companionForId(selectedAvatarId);
    final theme = Theme.of(context);
    return KikiCard(
      variant: KikiCardVariant.highlighted,
      child: Row(
        children: [
          KikiAvatarFrame(
            assetPath: option.assetPath,
            fallbackIcon: option.fallbackIcon,
            size: 64,
            padding: 3,
            semanticLabel: option.name,
          ),
          const SizedBox(width: KikiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tu compa\u00f1ero', style: theme.textTheme.titleMedium),
                const SizedBox(height: KikiSpacing.xs),
                Text('${option.name}: ${option.description}'),
              ],
            ),
          ),
          TextButton(onPressed: onChange, child: const Text('Cambiar')),
        ],
      ),
    );
  }
}

class _AccountStatusCard extends StatelessWidget {
  final BudgetProvider budget;

  const _AccountStatusCard({required this.budget});

  @override
  Widget build(BuildContext context) {
    return KikiCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.workspace_premium_rounded,
            color: KikiColors.primary),
        title: const Text('Estado de la cuenta'),
        subtitle: Text(
          budget.isTrialActive
              ? 'Pro Trial activo (${budget.trialDaysLeft} d\u00edas restantes)'
              : budget.isPro
                  ? 'Kiki Pro activo'
                  : 'Versi\u00f3n Free',
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
    return KikiCard(
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: KikiSpacing.lg),
          TextField(
            controller: budgetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Presupuesto mensual',
              prefixText: '$currencySymbol ',
            ),
          ),
          const SizedBox(height: KikiSpacing.lg),
          DropdownButtonFormField<String>(
            initialValue: selectedCurrency,
            decoration: const InputDecoration(labelText: 'Moneda'),
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
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final List<String> incomeLabels;
  final List<String> expenseLabels;
  final List<String> goalLabels;
  final String primaryGoalLabel;
  final VoidCallback onEdit;
  final VoidCallback onReset;

  const _ExperienceCard({
    required this.incomeLabels,
    required this.expenseLabels,
    required this.goalLabels,
    required this.primaryGoalLabel,
    required this.onEdit,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return KikiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tu experiencia',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: KikiSpacing.md),
          _ExperienceLine(
            label: 'Ingresos',
            value: incomeLabels.isEmpty
                ? 'Sin personalizar'
                : incomeLabels.join(', '),
          ),
          _ExperienceLine(
            label: 'Egresos principales',
            value: expenseLabels.isEmpty
                ? 'Todas disponibles'
                : expenseLabels.join(', '),
          ),
          _ExperienceLine(
            label: 'Objetivos',
            value: goalLabels.isEmpty
                ? 'Sin objetivos seleccionados'
                : goalLabels.join(', '),
          ),
          _ExperienceLine(
              label: 'Prioridad principal', value: primaryGoalLabel),
          const SizedBox(height: KikiSpacing.md),
          Wrap(
            spacing: KikiSpacing.sm,
            runSpacing: KikiSpacing.sm,
            children: [
              KikiButton(
                  label: 'Editar preferencias',
                  icon: Icons.tune,
                  onPressed: onEdit),
              KikiButton(
                label: 'Restablecer personalizaci\u00f3n',
                variant: KikiButtonVariant.text,
                onPressed: onReset,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetSummaryCard extends StatelessWidget {
  final BudgetProvider budget;

  const _BudgetSummaryCard({required this.budget});

  @override
  Widget build(BuildContext context) {
    return KikiCard(
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.account_balance_wallet,
                color: KikiColors.primary),
            title: const Text('Presupuesto actual'),
            subtitle: Text(
                '${budget.currencySymbol}${budget.monthlyBudget.toStringAsFixed(2)}'),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                const Icon(Icons.currency_exchange, color: KikiColors.primary),
            title: const Text('Moneda activa'),
            subtitle: Text(budget.currencyCode),
          ),
        ],
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
      padding: const EdgeInsets.only(bottom: KikiSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: KikiSpacing.xs),
          Text(value),
        ],
      ),
    );
  }
}

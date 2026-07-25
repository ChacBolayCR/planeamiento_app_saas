import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/financial_profile_provider.dart';
import '../../services/category_catalog.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final bool editMode;

  const OnboardingScreen({
    super.key,
    this.editMode = false,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  final Set<String> _incomeTypes = {};
  final Set<String> _expenseCategories = {};
  String? _primaryGoal;
  int _page = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final profile = context.read<FinancialProfileProvider>().profile;
      setState(() {
        _incomeTypes.addAll(profile.selectedIncomeTypes);
        _expenseCategories.addAll(profile.selectedExpenseCategories);
        _primaryGoal = profile.primaryGoal;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish({bool skipped = false}) async {
    setState(() => _saving = true);
    await context.read<FinancialProfileProvider>().completeOnboarding(
          incomeTypes: skipped ? const [] : _incomeTypes.toList(),
          expenseCategories: skipped ? const [] : _expenseCategories.toList(),
          primaryGoal: skipped ? null : _primaryGoal,
        );

    if (!mounted) return;

    if (widget.editMode) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _next() {
    if (_page == 2) {
      _finish();
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: widget.editMode
          ? AppBar(title: const Text('Editar preferencias'))
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_page + 1) / 3,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${_page + 1}/3'),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (value) => setState(() => _page = value),
                children: [
                  _OptionsStep(
                    title: '¿De dónde provienen tus ingresos?',
                    helper:
                        'Ingreso es el dinero que recibes, por ejemplo salario, ventas o servicios.',
                    kikiMessage:
                        'Voy a usar tus respuestas para mostrarte primero lo que más importa para ti.',
                    options: CategoryCatalog.incomeOptions,
                    selectedIds: _incomeTypes,
                    onToggle: (id) => setState(() {
                      _incomeTypes.contains(id)
                          ? _incomeTypes.remove(id)
                          : _incomeTypes.add(id);
                    }),
                  ),
                  _OptionsStep(
                    title: '¿Qué egresos forman parte de tu vida?',
                    helper:
                        'Egreso es el dinero que utilizas para cubrir gastos, pagos y compromisos.',
                    kikiMessage:
                        'Así Kiki puede poner tus categorías importantes más a mano.',
                    options: CategoryCatalog.expenseProfileOptions,
                    selectedIds: _expenseCategories,
                    onToggle: (id) => setState(() {
                      _expenseCategories.contains(id)
                          ? _expenseCategories.remove(id)
                          : _expenseCategories.add(id);
                    }),
                  ),
                  _GoalStep(
                    selectedGoal: _primaryGoal,
                    onChanged: (id) => setState(() => _primaryGoal = id),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _next,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_page == 2 ? 'Preparar mi Kiki' : 'Siguiente'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _saving ? null : () => _finish(skipped: true),
                child: Text(
                  'Omitir por ahora',
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

class _OptionsStep extends StatelessWidget {
  final String title;
  final String helper;
  final String kikiMessage;
  final List<FinancialProfileOption> options;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  const _OptionsStep({
    required this.title,
    required this.helper,
    required this.kikiMessage,
    required this.options,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _KikiHeader(message: kikiMessage),
          const SizedBox(height: 18),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          _HelperText(text: helper),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options
                .map(
                  (option) => _SelectableOption(
                    option: option,
                    selected: selectedIds.contains(option.id),
                    onTap: () => onToggle(option.id),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _GoalStep extends StatelessWidget {
  final String? selectedGoal;
  final ValueChanged<String> onChanged;

  const _GoalStep({required this.selectedGoal, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _KikiHeader(
            message:
                'Con tu objetivo principal, Kiki puede ordenar mejor tus primeras tarjetas.',
          ),
          const SizedBox(height: 18),
          Text(
            '¿Qué quieres lograr con Kiki?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 16),
          ...CategoryCatalog.goalOptions.map(
            (goal) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SelectableOption(
                option: goal,
                selected: selectedGoal == goal.id,
                onTap: () => onChanged(goal.id),
                fullWidth: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KikiHeader extends StatelessWidget {
  final String message;

  const _KikiHeader({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/kiki/kiki_neutral.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelperText extends StatelessWidget {
  final String text;

  const _HelperText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _SelectableOption extends StatelessWidget {
  final FinancialProfileOption option;
  final bool selected;
  final VoidCallback onTap;
  final bool fullWidth;

  const _SelectableOption({
    required this.option,
    required this.selected,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Icon(option.icon, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                option.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle, size: 18),
            ],
          ],
        ),
      ),
    );

    if (fullWidth) return child;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: child,
    );
  }
}

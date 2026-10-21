import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design_system/components/kiki_avatar_frame.dart';
import '../../design_system/components/kiki_button.dart';
import '../../design_system/components/kiki_card.dart';
import '../../design_system/components/kiki_choice_card.dart';
import '../../design_system/kiki_spacing.dart';
import '../../models/financial_profile.dart';
import '../../providers/financial_profile_provider.dart';
import '../../services/category_catalog.dart';
import '../../utils/kiki_avatar_assets.dart';
import '../dashboard/dashboard_screen.dart';

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
  static const int _configurableStepCount = 4;

  final PageController _controller = PageController();
  final Set<String> _incomeTypes = {};
  final Set<String> _expenseCategories = {};
  final Set<String> _selectedGoals = {};

  String? _primaryGoal;
  String _selectedAvatarId = FinancialProfile.defaultAvatarId;
  int _page = 0;
  bool _showIntro = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _showIntro = !widget.editMode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final profile = context.read<FinancialProfileProvider>().profile;
      setState(() {
        _incomeTypes.addAll(profile.selectedIncomeTypes);
        _expenseCategories.addAll(profile.selectedExpenseCategories);
        _selectedGoals.addAll(profile.selectedGoals);
        _primaryGoal = profile.primaryGoal;
        _selectedAvatarId = profile.selectedAvatarId;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish({bool skipped = false}) async {
    if (!skipped && _selectedGoals.isNotEmpty && _primaryGoal == null) {
      _showPriorityMessage();
      return;
    }

    setState(() => _saving = true);
    await context.read<FinancialProfileProvider>().completeOnboarding(
          incomeTypes: skipped ? const [] : _incomeTypes.toList(),
          expenseCategories: skipped ? const [] : _expenseCategories.toList(),
          selectedGoals: skipped ? const [] : _selectedGoals.toList(),
          primaryGoal: skipped ? null : _primaryGoal,
          selectedAvatarId:
              skipped ? FinancialProfile.defaultAvatarId : _selectedAvatarId,
        );

    if (!mounted) return;

    if (widget.editMode) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  void _next() {
    if (_page == 2 && _selectedGoals.isNotEmpty && _primaryGoal == null) {
      _showPriorityMessage();
      return;
    }

    if (_page == 4) {
      _finish();
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _back() {
    if (_page == 0) {
      if (widget.editMode) Navigator.pop(context);
      return;
    }

    _controller.previousPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  void _toggleGoal(String id) {
    setState(() {
      if (_selectedGoals.contains(id)) {
        _selectedGoals.remove(id);
        if (_primaryGoal == id) _primaryGoal = null;
      } else {
        _selectedGoals.add(id);
        _primaryGoal ??= id;
      }
    });
  }

  void _showPriorityMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Elige tu prioridad principal para continuar.'),
        behavior: SnackBarBehavior.floating,
      ),
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
        child: _showIntro
            ? _IntroStep(
                onStart: () => setState(() => _showIntro = false),
                onSkip: _saving ? null : () => _finish(skipped: true),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value:
                                ((_page + 1).clamp(1, _configurableStepCount)) /
                                    _configurableStepCount,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${(_page + 1).clamp(1, _configurableStepCount)}/$_configurableStepCount',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _controller,
                      onPageChanged: (value) => setState(() => _page = value),
                      children: [
                        _OptionsStep(
                          title: '\u00bfDe d\u00f3nde provienen tus ingresos?',
                          helper:
                              'Ingreso es el dinero que recibes, por ejemplo salario, ventas o servicios.',
                          companionMessage:
                              'Voy a usar tus respuestas para mostrarte primero lo que m\u00e1s importa para ti.',
                          options: CategoryCatalog.incomeOptions,
                          selectedIds: _incomeTypes,
                          onToggle: (id) => setState(() {
                            _incomeTypes.contains(id)
                                ? _incomeTypes.remove(id)
                                : _incomeTypes.add(id);
                          }),
                        ),
                        _OptionsStep(
                          title:
                              '\u00bfQu\u00e9 egresos forman parte de tu vida?',
                          helper:
                              'Egreso es el dinero que utilizas para cubrir gastos, pagos y compromisos.',
                          companionMessage:
                              'As\u00ed Kiki puede poner tus categor\u00edas importantes m\u00e1s a mano.',
                          options: CategoryCatalog.expenseProfileOptions,
                          selectedIds: _expenseCategories,
                          onToggle: (id) => setState(() {
                            _expenseCategories.contains(id)
                                ? _expenseCategories.remove(id)
                                : _expenseCategories.add(id);
                          }),
                        ),
                        _GoalStep(
                          selectedGoals: _selectedGoals,
                          primaryGoal: _primaryGoal,
                          onToggleGoal: _toggleGoal,
                          onPrimaryChanged: (id) {
                            setState(() => _primaryGoal = id);
                          },
                        ),
                        _CompanionStep(
                          selectedAvatarId: _selectedAvatarId,
                          onChanged: (id) {
                            setState(() => _selectedAvatarId = id);
                          },
                        ),
                        _SummaryStep(
                          incomeIds: _incomeTypes.toList(),
                          expenseIds: _expenseCategories.toList(),
                          goalIds: _selectedGoals.toList(),
                          primaryGoal: _primaryGoal,
                          selectedAvatarId: _selectedAvatarId,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: _showIntro
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        if (_page > 0 || widget.editMode) ...[
                          Expanded(
                            child: KikiButton(
                              label: 'Atr\u00e1s',
                              variant: KikiButtonVariant.outline,
                              onPressed: _saving ? null : _back,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 50,
                            child: KikiButton(
                              label: _page == 4
                                  ? 'Preparar mi Kiki'
                                  : _page == 3
                                      ? 'Ver resumen'
                                      : 'Siguiente',
                              onPressed: _saving ? null : _next,
                              loading: _saving,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _saving ? null : () => _finish(skipped: true),
                      child: Text(
                        'Omitir por ahora',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
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

class _IntroStep extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback? onSkip;

  const _IntroStep({required this.onStart, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Image.asset(
              KikiAvatarAssets.wave,
              height: 174,
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Vamos a preparar Kiki para ti',
            key: const ValueKey('intro_title'),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Responder\u00e1s unas preguntas r\u00e1pidas para que Kiki muestre primero lo que m\u00e1s te importa. No se crear\u00e1n gastos ni se modificar\u00e1n tus datos, y podr\u00e1s cambiar estas preferencias despu\u00e9s.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.35),
          ),
          const SizedBox(height: 10),
          Text(
            'Tomar\u00e1 menos de un minuto.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 50,
            child: KikiButton(
              key: const ValueKey('begin_onboarding'),
              label: 'Comenzar',
              onPressed: onStart,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            key: const ValueKey('skip_onboarding'),
            onPressed: onSkip,
            child: const Text('Omitir por ahora'),
          ),
        ],
      ),
    );
  }
}

class _OptionsStep extends StatelessWidget {
  final String title;
  final String helper;
  final String companionMessage;
  final List<FinancialProfileOption> options;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  const _OptionsStep({
    required this.title,
    required this.helper,
    required this.companionMessage,
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
          _CompanionHeader(message: companionMessage),
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
  final Set<String> selectedGoals;
  final String? primaryGoal;
  final ValueChanged<String> onToggleGoal;
  final ValueChanged<String> onPrimaryChanged;

  const _GoalStep({
    required this.selectedGoals,
    required this.primaryGoal,
    required this.onToggleGoal,
    required this.onPrimaryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CompanionHeader(
            message:
                'Puedes elegir varias metas y marcar cu\u00e1l quieres priorizar primero.',
            assetPath: KikiAvatarAssets.motivating,
          ),
          const SizedBox(height: 18),
          Text(
            '\u00bfQu\u00e9 quieres lograr con Kiki?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Puedes elegir m\u00e1s de una opci\u00f3n.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ...CategoryCatalog.goalOptions.map(
            (goal) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SelectableOption(
                key: ValueKey('goal_${goal.id}'),
                option: goal,
                selected: selectedGoals.contains(goal.id),
                onTap: () => onToggleGoal(goal.id),
                fullWidth: true,
              ),
            ),
          ),
          if (selectedGoals.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '\u00bfCu\u00e1l es tu prioridad principal?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: primaryGoal,
              onChanged: (value) {
                if (value != null) onPrimaryChanged(value);
              },
              child: Column(
                children: CategoryCatalog.goalOptions
                    .where((goal) => selectedGoals.contains(goal.id))
                    .map(
                      (goal) => RadioListTile<String>(
                        key: ValueKey('priority_${goal.id}'),
                        value: goal.id,
                        title: Text(goal.label),
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompanionStep extends StatelessWidget {
  final String selectedAvatarId;
  final ValueChanged<String> onChanged;

  const _CompanionStep({
    required this.selectedAvatarId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CompanionHeader(
            message:
                'Elige qui\u00e9n te acompa\u00f1ar\u00e1 mientras ordenas tus finanzas.',
          ),
          const SizedBox(height: 18),
          Text(
            'Elige tu compa\u00f1ero',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pr\u00f3ximamente podr\u00e1s usar tu propia foto.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 380;
              final cards = CategoryCatalog.companionOptions
                  .map(
                    (option) => _CompanionChoiceCard(
                      option: option,
                      selected: selectedAvatarId == option.id,
                      onTap: () => onChanged(option.id),
                    ),
                  )
                  .toList();

              if (narrow) {
                return Column(
                  children: cards
                      .map(
                        (card) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: card,
                        ),
                      )
                      .toList(),
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: cards
                    .map(
                      (card) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: card,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryStep extends StatelessWidget {
  final List<String> incomeIds;
  final List<String> expenseIds;
  final List<String> goalIds;
  final String? primaryGoal;
  final String selectedAvatarId;

  const _SummaryStep({
    required this.incomeIds,
    required this.expenseIds,
    required this.goalIds,
    required this.primaryGoal,
    required this.selectedAvatarId,
  });

  @override
  Widget build(BuildContext context) {
    final companion = CategoryCatalog.companionForId(selectedAvatarId);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CompanionHeader(
            message:
                'Listo. Estas preferencias solo ordenan tu experiencia; tus datos financieros no cambian.',
            avatarId: selectedAvatarId,
            assetPath: KikiAvatarAssets.happy,
          ),
          const SizedBox(height: 18),
          Text(
            'Resumen final',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 16),
          _SummaryLine(
            label: 'Fuentes de ingreso',
            value: _labels(incomeIds, CategoryCatalog.labelForIncome,
                fallback: 'Sin personalizar'),
          ),
          _SummaryLine(
            label: 'Categor\u00edas de egreso',
            value: _labels(expenseIds, CategoryCatalog.labelForExpenseProfile,
                fallback: 'Todas disponibles'),
          ),
          _SummaryLine(
            label: 'Objetivos',
            value: _labels(goalIds, CategoryCatalog.labelForGoal,
                fallback: 'Sin objetivos seleccionados'),
          ),
          _SummaryLine(
            label: 'Prioridad principal',
            value: CategoryCatalog.labelForGoal(primaryGoal),
          ),
          _SummaryLine(label: 'Compa\u00f1ero', value: companion.name),
        ],
      ),
    );
  }

  String _labels(
    List<String> ids,
    String Function(String) labelFor, {
    required String fallback,
  }) {
    if (ids.isEmpty) return fallback;
    return ids.map(labelFor).join(', ');
  }
}

class _CompanionHeader extends StatelessWidget {
  final String message;
  final String avatarId;
  final String? assetPath;

  const _CompanionHeader({
    required this.message,
    this.avatarId = FinancialProfile.defaultAvatarId,
    this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    final option = CategoryCatalog.companionForId(avatarId);
    final theme = Theme.of(context);

    return KikiCard(
      padding: const EdgeInsets.all(KikiSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CompanionAvatar(
            option: option,
            size: 56,
            padding: 3,
            assetPath: assetPath,
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
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = KikiChoiceCard(
      title: option.label,
      icon: option.icon,
      selected: selected,
      onTap: onTap,
      fullWidth: fullWidth,
    );

    if (fullWidth) return card;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: card,
    );
  }
}

class _CompanionChoiceCard extends StatelessWidget {
  final FinancialCompanionOption option;
  final bool selected;
  final VoidCallback onTap;

  const _CompanionChoiceCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      key: ValueKey('companion_${option.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CompanionAvatar(
                option: option, size: 88, padding: 3, selected: selected),
            const SizedBox(height: 10),
            Text(
              option.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              option.description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanionAvatar extends StatelessWidget {
  final FinancialCompanionOption option;
  final double size;
  final double padding;
  final bool selected;
  final String? assetPath;

  const _CompanionAvatar({
    required this.option,
    required this.size,
    required this.padding,
    this.selected = false,
    this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return KikiAvatarFrame(
      assetPath: assetPath ?? option.assetPath,
      fallbackIcon: option.fallbackIcon,
      size: size,
      padding: padding,
      selected: selected,
      semanticLabel: option.name,
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(value),
          ],
        ),
      ),
    );
  }
}

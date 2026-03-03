import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';
import '../expenses/expenses_screen.dart';

import '../../widgets/month_selector.dart';
import '../../widgets/monthly_overview_card.dart';
import '../../widgets/category_card.dart';
import '../../widgets/pro_blur_overlay.dart';
import '../../widgets/kiki_assistant.dart';
import '../../widgets/kiki_message_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().checkNewMonth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kiki Finance')),
      body: DashboardHome(),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();

    final monthExpenses = budget.currentMonthExpenses;
    final hasMonthExpenses = monthExpenses.isNotEmpty;
    final double monthSpent = budget.currentMonthTotalSpent;

    final double percentUsed =
        budget.monthlyBudget == 0 ? 0.0 : (monthSpent / budget.monthlyBudget).toDouble();

    // ✅ Estado + mensaje + botón opcional
    KikiMood mood;
    String message;

    String? actionLabel;
    VoidCallback? onAction;

    if (budget.isNewMonth) {
      mood = KikiMood.neutral;
      message = 'Empezamos un nuevo mes 🗓️ Una nueva oportunidad de ahorrar. ¿Arrancamos?';
    } else if (!hasMonthExpenses) {
      mood = KikiMood.neutral;
      message = 'Este mes está vacío 🐾 Tip: agrega tu primer gasto con el botón “+”.';
    } else if (percentUsed >= 1.0) {
      mood = KikiMood.overbudget;
      message = 'Nos pasamos del presupuesto 😅 Vamos a revisar qué pasó y lo ajustamos.';
      actionLabel = 'Revisar gastos';
      onAction = () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen()));
      };
    } else if (percentUsed >= 0.8) {
      mood = KikiMood.warning;
      message = 'Ojo 👀 ya vamos alto este mes. ¿Revisamos los gastos antes de pasarnos?';
      actionLabel = 'Revisar gastos';
      onAction = () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen()));
      };
    } else if (percentUsed < 0.5) {
      mood = KikiMood.happy;
      message = '¡Vamos genial! Tus gastos están bajo control 🐾';
    } else {
      mood = KikiMood.neutral;
      message = 'Vamos bien. Si mantenemos este ritmo, cerramos el mes tranquilos.';
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MonthSelector(
                selectedMonth: budget.selectedMonthDate,
                onChanged: budget.setSelectedMonthDate,
              ),
              const SizedBox(height: 12),

              if (!hasMonthExpenses) ...[
                _EmptyMonthCard(
                  onGoToday: () => budget.setSelectedMonthDate(DateTime.now()),
                ),
              ] else ...[
                // ✅ NUEVA card unificada (reemplaza ExpenseCard + BalanceCard)
                MonthlyOverviewCard(
                  budget: budget.monthlyBudget,
                  spent: monthSpent,
                  currencySymbol: budget.currencySymbol,
                ),
                const SizedBox(height: 12),

                // ✅ Categorías con “gate” Pro bien hecho:
                // El blur va ENCIMA de esta sección, dentro del scroll.
                Stack(
                  children: [
                    CategoryCard(
                      expenses: monthExpenses,
                      currencySymbol: budget.currencySymbol,
                    ),

                    // 🔒 Overlay encima: no se “escapa” con scroll.
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: true,
                        child: ProBlurOverlay(),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 260),
            ],
          ),
        ),

        // ❌ IMPORTANTE: ya NO ponemos ProBlurOverlay aquí
        // const ProBlurOverlay(),

        KikiAssistant(
          mood: mood,
          message: message,
          showOnStart: true,
          actionLabel: actionLabel,
          onAction: onAction,
          onDismiss: budget.isNewMonth
              ? () => context.read<BudgetProvider>().dismissNewMonthMessage()
              : null,
        ),
      ],
    );
  }
}

class _EmptyMonthCard extends StatelessWidget {
  final VoidCallback onGoToday;

  const _EmptyMonthCard({required this.onGoToday});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Agrega tus gastos para comenzar 🐾',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'No hay registros en este mes. Puedes volver al mes actual o crear tu primer gasto.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onGoToday,
                icon: const Icon(Icons.today),
                label: const Text('Volver al mes actual'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

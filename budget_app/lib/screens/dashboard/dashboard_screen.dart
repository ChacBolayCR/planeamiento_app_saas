import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';
import '../expenses/expenses_screen.dart';

import '../../widgets/month_selector.dart';
import '../../widgets/monthly_overview_card.dart';
import '../../widgets/category_card.dart';
import '../../widgets/kiki_assistant.dart';
import '../../widgets/kiki_message_card.dart';
import '../../widgets/locked_pro_card.dart';

import '../expenses/add_expenses_modal.dart';

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
    return const Scaffold(
      appBar: _DashAppBar(),
      body: DashboardHome(),
    );
  }
}

class _DashAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DashAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Kiki Finance'),
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  bool _isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();

    final selected = budget.selectedMonthDate;
    final now = DateTime.now();
    final isCurrentMonth = _isSameMonth(selected, now);

    final monthExpenses = budget.currentMonthExpenses;
    final hasMonthExpenses = monthExpenses.isNotEmpty;
    final monthSpent = budget.currentMonthTotalSpent;

    final percentUsed = budget.monthlyBudget == 0
        ? 0.0
        : (monthSpent / budget.monthlyBudget).clamp(0.0, 10.0);

    // ✅ Mensajes Kiki + CTA contextual
    KikiMood mood;
    String message;
    String? actionLabel;
    VoidCallback? onAction;

    void openAddExpense() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => const AddExpenseModal(),
      );
    }

    if (budget.isNewMonth) {
      mood = KikiMood.neutral;
      message = 'Nuevo mes 🗓️ ¿Definimos presupuesto y arrancamos?';
    } else if (!hasMonthExpenses) {
      mood = KikiMood.neutral;

      if (isCurrentMonth) {
        message = 'Este mes está vacío 🐾 ¿Agregamos tu primer gasto?';
        actionLabel = 'Agregar gasto';
        onAction = openAddExpense;
      } else {
        message = 'Este mes no tiene gastos registrados. Puedes volver al mes actual o agregar uno aquí.';
        actionLabel = 'Ir al mes actual';
        onAction = () => budget.setSelectedMonthDate(now);
      }
    } else if (percentUsed >= 1.0) {
      mood = KikiMood.overbudget;
      message = 'Nos pasamos del presupuesto 😅 ¿Revisamos los gastos?';
      actionLabel = 'Revisar gastos';
      onAction = () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ExpensesScreen()),
      );
    } else if (percentUsed >= 0.8) {
      mood = KikiMood.warning;
      message = 'Ojo 👀 ya vamos alto este mes. ¿Revisamos antes de pasarnos?';
      actionLabel = 'Revisar gastos';
      onAction = () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ExpensesScreen()),
      );
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
                selectedMonth: selected,
                onChanged: budget.setSelectedMonthDate,
              ),
              const SizedBox(height: 12),

              if (!hasMonthExpenses) ...[
                _EmptyMonthCard(
                  isCurrentMonth: isCurrentMonth,
                  onGoToday: () => budget.setSelectedMonthDate(now),
                  onAddExpense: openAddExpense,
                ),
              ] else ...[
                MonthlyOverviewCard(
                  budget: budget.monthlyBudget,
                  spent: monthSpent,
                  currencySymbol: budget.currencySymbol,
                ),
                const SizedBox(height: 12),

                // 🔒 Gate Pro real: Free no renderiza nada Pro
                if (budget.isPro)
                  CategoryCard(
                    expenses: monthExpenses,
                    currencySymbol: budget.currencySymbol,
                  )
                else
                  const LockedProCard(
                    title: 'Gastos por categoría',
                    subtitle: 'Desbloquea categorías, reportes y análisis mensual.',
                  ),
              ],

              const SizedBox(height: 260),
            ],
          ),
        ),

        KikiAssistant(
          mood: mood,
          message: message,
          showOnStart: true,
          actionLabel: actionLabel,
          onAction: onAction,
          onDismiss: budget.isNewMonth ? budget.dismissNewMonthMessage : null,
        ),
      ],
    );
  }
}

class _EmptyMonthCard extends StatelessWidget {
  final bool isCurrentMonth;
  final VoidCallback onGoToday;
  final VoidCallback onAddExpense;

  const _EmptyMonthCard({
    required this.isCurrentMonth,
    required this.onGoToday,
    required this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    final title = isCurrentMonth
        ? 'Empecemos este mes 🐾'
        : 'Mes sin movimientos';

    final desc = isCurrentMonth
        ? 'Aún no hay gastos. Agrega el primero y empezamos a registrar.'
        : 'No hay gastos en este mes. Puedes volver al mes actual o agregar uno aquí.';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAddExpense,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Agregar gasto'),
              ),
            ),

            if (!isCurrentMonth) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onGoToday,
                  icon: const Icon(Icons.today),
                  label: const Text('Ir al mes actual'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
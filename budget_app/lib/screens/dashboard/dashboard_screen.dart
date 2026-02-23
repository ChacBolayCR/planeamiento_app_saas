import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';

import '../../widgets/month_selector.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/balance_card.dart';
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

    // ✅ Revisa cambio de mes una sola vez al entrar al Dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().checkNewMonth();
    });
  }

  @override
  Widget build(BuildContext context) {
    // OJO: NO usamos "hasExpenses" para decidir si el dashboard existe.
    // El dashboard siempre existe, pero puede mostrar EmptyState por mes.
    return Scaffold(
  appBar: AppBar(
    title: const Text('Kiki Finance'),
    backgroundColor: Colors.transparent,
    elevation: 0,
  ),
  extendBodyBehindAppBar: false,
  body: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF8F6F2), // beige suave cálido
          Color(0xFFFFFFFF), // blanco
        ],
      ),
    ),
    child: const DashboardHome(),
  ),
);
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();

    // ✅ Datos del mes seleccionado
    final monthExpenses = budget.currentMonthExpenses;
    final hasMonthExpenses = monthExpenses.isNotEmpty;
    final double monthSpent = budget.currentMonthTotalSpent;

    final double percentUsed = budget.monthlyBudget == 0
        ? 0.0
        : (monthSpent / budget.monthlyBudget).toDouble();

    // ✅ Mensaje de Kiki (incluye “nuevo mes”)
    KikiMood mood;
    String message;

    if (budget.isNewMonth) {
      mood = KikiMood.neutral;
      message =
          '¡Nuevo mes! 🗓️ Empecemos de cero: agrega tus gastos para este mes.';
    } else if (!hasMonthExpenses) {
      mood = KikiMood.neutral;
      message = 'Este mes está vacío 🐾 ¿Agregamos el primer gasto?';
    } else if (percentUsed < 0.5) {
      mood = KikiMood.happy;
      message = '¡Vamos genial! Tus gastos están bajo control 🐾';
    } else if (percentUsed < 0.8) {
      mood = KikiMood.neutral;
      message = 'Vamos bien, pero ojo con los próximos gastos 👀';
    } else {
      mood = KikiMood.warning;
      message = 'Cuidado… estamos llegando al límite del presupuesto';
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ✅ Selector de mes navegable (con "Hoy" + flechas)
              MonthSelector(
                selectedMonth: budget.selectedMonthDate,
                onChanged: budget.setSelectedMonthDate,
              ),
              const SizedBox(height: 12),

              // ✅ Si el mes no tiene datos, no “rompas” el dashboard:
              // muestra un empty-state por mes y deja volver a "Hoy".
              if (!hasMonthExpenses) ...[
                _EmptyMonthCard(
                  onGoToday: () => budget.setSelectedMonthDate(DateTime.now()),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                            // navegar a expenses screen
                  },
                  icon: Icon(Icons.add),
                  label: Text('Agregar gasto'),
                )
              ] else ...[
                ExpenseCard(
                  totalExpenses: monthSpent,
                  currencySymbol: budget.currencySymbol,
                ),
                const SizedBox(height: 12),

                BalanceCard(
                  budget: budget.monthlyBudget,
                  spent: monthSpent,
                  currencySymbol: budget.currencySymbol,
                ),
                const SizedBox(height: 12),

                CategoryCard(
                  expenses: monthExpenses,
                  currencySymbol: budget.currencySymbol,
                ),
              ],

              // espacio para que overlay + kiki no tapen el final
              const SizedBox(height: 220),
            ],
          ),
        ),

        // 🔒 Blur Pro (abajo)
        const ProBlurOverlay(),

        // 🐱 Kiki flotante (asistente)
        KikiAssistant(
          mood: mood,
          message: message,
          // Solo permitimos “dismiss” cuando es mensaje de nuevo mes
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
          ],
        ),
      ),
    );
  }
}

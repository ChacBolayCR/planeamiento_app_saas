import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';

import '../../widgets/empty_home.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/insight_card.dart';
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
    final budget = context.watch<BudgetProvider>();

    // ✅ Vacio = no hay gastos en el mes actual
    final hasMonthExpenses = budget.currentMonthExpenses.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiki Finance'),
      ),
      body: hasMonthExpenses ? const DashboardHome() : const EmptyHome(),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().checkNewMonth();
    });

    // ✅ Totales SOLO del mes actual
    final double monthSpent = budget.currentMonthTotalSpent;

    final double percentUsed = budget.monthlyBudget == 0
        ? 0.0
        : (monthSpent / budget.monthlyBudget).toDouble();

    // ✅ Mensaje de Kiki (incluye “nuevo mes”)
    KikiMood mood;
    String message;

    if (budget.isNewMonth) {
      mood = KikiMood.neutral;
      message = '¡Nuevo mes! 🗓️ Empecemos de cero: agrega tus gastos para este mes.';
    } else if (percentUsed < 0.5) {
      mood = KikiMood.happy;
      message = '¡Vamos genial! Tus gastos están bajo control 🐾';
    } else if (percentUsed < 0.8) {
      mood = KikiMood.neutral;
      message = 'Vamos bien, pero ojo con los próximos gastos 👀';
    } else {
      mood = KikiMood.warning;
      message = 'Cuidado… estamos llegando al límite del presupuesto 💳';
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MonthSelector(selectedMonth: budget.selectedMonth, onChanged: budget.setSelectedMonth),
              const SizedBox(height: 12),

              // (Opcional) si quieres un “mensaje” como card arriba,
              // puedes dejarlo, pero como ya tenemos Kiki flotante,
              // lo dejo fuera para que no sea redundante.
              //
              // KikiMessageCard(mood: mood, message: message),
              // const SizedBox(height: 12),

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

              InsightCard(
                dominantCategory: budget.currentMonthDominantCategory,
                percentUsed: percentUsed,
              ),
              const SizedBox(height: 16),

              CategoryCard(
                expenses: budget.currentMonthExpenses,
                currencySymbol: budget.currencySymbol,
              ),

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
          onDismiss: budget.isNewMonth
          ? () => context.read<BudgetProvider>().dismissNewMonthMessage()
          : null,
        ),
      ],
    );
  }
}

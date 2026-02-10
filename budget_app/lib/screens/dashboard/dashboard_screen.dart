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
import '../../widgets/kiki_message_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final hasExpenses = budget.expenses.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiki Finance'),
      ),
      body: hasExpenses ? const DashboardHome() : const EmptyHome(),
    );
  }
}

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  late DateTime selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();

    // ✅ Detecta cambio de mes (Kiki lo anuncia)
    budget.checkNewMonth();

    final double percentUsed = budget.monthlyBudget == 0
        ? 0.0
        : (budget.totalSpent / budget.monthlyBudget).toDouble();

    KikiMood mood;
    String message;

    if (budget.isNewMonth) {
      mood = KikiMood.happy;
      message = '¡Nuevo mes! 🗓️ Empezamos de cero, vamos con calma 💙';
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
              // ✅ Month selector real
              MonthSelector(
                selectedMonth: selectedMonth,
                onChanged: (m) => setState(() => selectedMonth = m),
              ),
              const SizedBox(height: 12),

              // ✅ Kiki banner compacto
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: KikiMessageCard(mood: mood, message: message),
              ),

              const SizedBox(height: 12),

              ExpenseCard(
                totalExpenses: budget.totalSpent,
                currencySymbol: budget.currencySymbol,
              ),
              const SizedBox(height: 12),

              BalanceCard(
                budget: budget.monthlyBudget,
                spent: budget.totalSpent,
                currencySymbol: budget.currencySymbol,
              ),
              const SizedBox(height: 12),

              InsightCard(
                dominantCategory: budget.getDominantCategory(),
                percentUsed: percentUsed,
              ),
              const SizedBox(height: 16),

              CategoryCard(
                expenses: budget.expenses,
                currencySymbol: budget.currencySymbol,
              ),

              // espacio para que el overlay no tape el final
              const SizedBox(height: 240),
            ],
          ),
        ),

        // ✅ Blur Pro fijo abajo
        const ProBlurOverlay(),
      ],
    );
  }
}

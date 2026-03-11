import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';
import '../../services/kiki_insights_service.dart';

import '../debug/debug_panel_screen.dart';
import '../expenses/add_expenses_modal.dart';
import '../expenses/expenses_screen.dart';

import '../../widgets/category_bar_chart_card.dart';
import '../../widgets/dominant_category_card.dart';
import '../../widgets/kiki_assistant.dart';
import '../../widgets/kiki_message_card.dart';
import '../../widgets/kiki_score_card.dart';
import '../../widgets/locked_pro_card.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/monthly_overview_card.dart';
import '../../widgets/monthly_trend_chart_card.dart';
import '../../widgets/secret_tap_detector.dart';

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
      if (!mounted) return;
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
      title: SecretTapDetector(
        onUnlocked: () {
          if (!kDebugMode) return;

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DebugPanelScreen()),
          );
        },
        child: const Text('Kiki Budget'),
      ),
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();

    final selected = budget.selectedMonthDate;
    final now = DateTime.now();
    final isCurrentMonth = _isSameMonth(selected, now);

    final monthExpenses = budget.currentMonthExpenses;
    final hasMonthExpenses = monthExpenses.isNotEmpty;
    final monthSpent = budget.currentMonthTotalSpent;

    final dominant = budget.currentMonthDominantCategory;
    final dominantAmount =
        dominant.isEmpty ? 0.0 : budget.totalByCategory(dominant);

    final freeLimit = BudgetProvider.freeMonthlyExpenseLimit;

    final previousMonth = DateTime(
      selected.year,
      selected.month - 1,
      1,
    );

    final lastMonthSpent = budget.totalSpentForMonth(previousMonth);

    final score = KikiInsightsService.financialScore(
      budget: budget.monthlyBudget,
      spent: monthSpent,
      expenses: monthExpenses,
    );

    final dailyInsight =
    KikiInsightsService.buildDailyInsight(monthExpenses);

    void openAddExpense() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => const AddExpenseModal(),
      );
    }

    void openExpenses() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ExpensesScreen()),
      );
    }

    final insight = KikiInsightsService.buildInsight(
      isNewMonth: budget.isNewMonth,
      isPro: budget.isPro,
      isCurrentMonth: isCurrentMonth,
      hasExpenses: hasMonthExpenses,
      expenseCount: monthExpenses.length,
      freeLimit: freeLimit,
      monthlyBudget: budget.monthlyBudget,
      totalSpent: monthSpent,
      dominantCategory: dominant,
      dominantAmount: dominantAmount,
      expenses: monthExpenses,
      lastMonthSpent: lastMonthSpent,
      selectedMonth: selected,
    );

    KikiMood mood;
    if (!hasMonthExpenses) {
      mood = KikiMood.neutral;
    } else if (budget.monthlyBudget > 0 &&
        monthSpent >= budget.monthlyBudget) {
      mood = KikiMood.overbudget;
    } else if (budget.monthlyBudget > 0 &&
        monthSpent >= budget.monthlyBudget * 0.85) {
      mood = KikiMood.warning;
    } else if (budget.monthlyBudget > 0 &&
        monthSpent < budget.monthlyBudget * 0.5) {
      mood = KikiMood.happy;
    } else {
      mood = KikiMood.neutral;
    }

    final String message = insight.message;
    final String? actionLabel = insight.actionLabel;

    VoidCallback? onAction;
    switch (insight.action) {
      case KikiInsightAction.addExpense:
        onAction = openAddExpense;
        break;
      case KikiInsightAction.viewExpenses:
        onAction = openExpenses;
        break;
      case KikiInsightAction.goToCurrentMonth:
        onAction = () => budget.setSelectedMonthDate(now);
        break;
      case KikiInsightAction.upgradePro:
        onAction = () {
          if (kDebugMode) {
            budget.setIsPro(true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pro activado (modo pruebas) ✅'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Pro ✨'),
              content: const Text(
                'Pro desbloquea gastos ilimitados, gráficas y tendencias. (Próximamente)',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Ok'),
                ),
              ],
            ),
          );
        };
        break;
      case KikiInsightAction.none:
        onAction = null;
        break;
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
                KikiScoreCard(score: score),
                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            dailyInsight,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                MonthlyOverviewCard(
                  budget: budget.monthlyBudget,
                  spent: monthSpent,
                  currencySymbol: budget.currencySymbol,
                ),
                const SizedBox(height: 12),

                DominantCategoryCard(
                  category: dominant,
                  amount: dominantAmount,
                  currencySymbol: budget.currencySymbol,
                ),
                const SizedBox(height: 12),

                if (budget.isPro) ...[
                  CategoryBarChartCard(
                    expenses: monthExpenses,
                    currencySymbol: budget.currencySymbol,
                  ),
                  const SizedBox(height: 12),
                  const MonthlyTrendChartCard(months: 6),
                ] else
                  const LockedProCard(
                    title: 'Gastos por categoría',
                    subtitle:
                        'Desbloquea categorías, reportes y análisis mensual.',
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
          onDismiss: budget.isNewMonth
              ? budget.dismissNewMonthMessage
              : null,
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
    final title =
        isCurrentMonth ? 'Empecemos este mes 🐾' : 'Mes sin movimientos';

    final desc = isCurrentMonth
        ? 'Aún no hay gastos. Agrega el primero y empezamos a registrar.'
        : 'No hay gastos en este mes. Puedes volver al mes actual o agregar uno aquí.';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
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
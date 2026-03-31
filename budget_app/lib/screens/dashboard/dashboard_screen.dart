import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';
import '../../services/kiki_insights_service.dart';
import '../../services/achievement_service.dart';

import '../../widgets/achievements_card.dart';
import '../../services/streak_service.dart';
import '../../widgets/category_bar_chart_card.dart';
import '../../widgets/dominant_category_card.dart';
import '../../widgets/kiki_message_card.dart';
import '../../widgets/kiki_score_card.dart';
import '../../widgets/locked_pro_card.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/monthly_overview_card.dart';
import '../../widgets/monthly_trend_chart_card.dart';
import '../../widgets/secret_tap_detector.dart';

import '../debug/debug_panel_screen.dart';
import '../expenses/add_expenses_modal.dart';
import '../expenses/expenses_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  int _index = 0;

  final _pages = const [
    DashboardHome(),
    ExpensesScreen(),
    ProfileScreen(),
  ];

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

    return Scaffold(
      appBar: const _DashAppBar(),

      body: _pages[_index],

      floatingActionButton: _index == 0
        ? FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => const AddExpenseModal(),
          );
        },
        child: const Icon(Icons.add),
      )
      : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,

        onTap: (i) {
          setState(() {
            _index = i;
          });
        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Gastos",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
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
    final hasExpenses = monthExpenses.isNotEmpty;
    final spent = budget.currentMonthTotalSpent;

    final dominant = budget.currentMonthDominantCategory;
    final dominantAmount =
        dominant.isEmpty ? 0.0 : budget.totalByCategory(dominant);

    final previousMonth = DateTime(selected.year, selected.month - 1, 1);
    final lastMonthSpent = budget.totalSpentForMonth(previousMonth);

    final freeLimit = BudgetProvider.freeMonthlyExpenseLimit;

    final score = KikiInsightsService.financialScore(
      budget: budget.monthlyBudget,
      spent: spent,
      expenses: monthExpenses,
    );

    final dailyInsight =
        KikiInsightsService.buildDailyInsight(monthExpenses);

    final achievements = AchievementService
        .evaluate(budget)
        .where((a) => a.unlocked)
        .toList();

    final streak = StreakService.calculateStreak(monthExpenses);

    void openAddExpense() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => const AddExpenseModal(),
      );
    }

    void openExpenses() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ExpensesScreen()),
      );
    }

    Widget quickAdd(String emoji, String category) {
      return GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) =>
                AddExpenseModal(prefilledCategory: category),
          );
        },
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(category, style: const TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    final insight = KikiInsightsService.buildInsight(
      isNewMonth: budget.isNewMonth,
      isPro: budget.isPro,
      isCurrentMonth: isCurrentMonth,
      hasExpenses: hasExpenses,
      expenseCount: monthExpenses.length,
      freeLimit: freeLimit,
      monthlyBudget: budget.monthlyBudget,
      totalSpent: spent,
      dominantCategory: dominant,
      dominantAmount: dominantAmount,
      expenses: monthExpenses,
      lastMonthSpent: lastMonthSpent,
      selectedMonth: selected,
    );

    KikiMood mood;
    if (!hasExpenses) {
      mood = KikiMood.neutral;
    } else if (budget.monthlyBudget > 0 &&
        spent >= budget.monthlyBudget) {
      mood = KikiMood.overbudget;
    } else if (spent >= budget.monthlyBudget * 0.85) {
      mood = KikiMood.warning;
    } else if (spent < budget.monthlyBudget * 0.5) {
      mood = KikiMood.happy;
    } else {
      mood = KikiMood.neutral;
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            /// 📅 MONTH
            MonthSelector(
              selectedMonth: selected,
              onChanged: budget.setSelectedMonthDate,
            ),

            const SizedBox(height: 16),

            /// 🐱 KIKI (TOP PRIORITY)
            KikiMessageCard(
              mood: mood,
              message: insight.message,
              actionLabel: insight.actionLabel,
              onAction: insight.action == KikiInsightAction.addExpense
                  ? openAddExpense
                  : insight.action == KikiInsightAction.viewExpenses
                      ? openExpenses
                      : null,
            ),

            const SizedBox(height: 16),

            /// ⚡ QUICK ACTIONS
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    quickAdd("☕", "Café"),
                    quickAdd("🍔", "Comida"),
                    quickAdd("🚕", "Transporte"),
                    quickAdd("🛒", "Compras"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 💰 CORE METRICS
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 140, // 👈 mismo alto para ambas
                    child: KikiScoreCard(score: score),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 140,
                    child: MonthlyOverviewCard(
                      budget: budget.monthlyBudget,
                      spent: spent,
                      currencySymbol: budget.currencySymbol,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// 🏆 ACHIEVEMENTS
            if (achievements.isNotEmpty) ...[
              AchievementsCard(achievements: achievements),
              const SizedBox(height: 16),
            ],

            /// 🔥 STREAK
            if (streak >= 2) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text("🔥", style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Text("$streak días seguidos 🔥"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            /// 🏷️ DOMINANT
            if (hasExpenses) ...[
              DominantCategoryCard(
                category: dominant,
                amount: dominantAmount,
                currencySymbol: budget.currencySymbol,
              ),
              const SizedBox(height: 16),
            ],

            /// 💡 INSIGHT
            if (hasExpenses) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline),
                      const SizedBox(width: 10),
                      Expanded(child: Text(dailyInsight)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            /// 🔒 PRO / CHARTS
            if (budget.isPro) ...[
              CategoryBarChartCard(
                expenses: monthExpenses,
                currencySymbol: budget.currencySymbol,
              ),
              const SizedBox(height: 16),
              const MonthlyTrendChartCard(months: 6),
            ] else
              const LockedProCard(
                title: 'Desbloquea Kiki Pro',
                subtitle: 'Gráficos, tendencias y coaching avanzado.',
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
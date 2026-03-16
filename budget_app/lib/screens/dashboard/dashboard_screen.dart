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

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => const AddExpenseModal(),
          );
        },
        child: const Icon(Icons.add),
      ),

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
    final hasMonthExpenses = monthExpenses.isNotEmpty;
    final monthSpent = budget.currentMonthTotalSpent;

    final dominant = budget.currentMonthDominantCategory;
    final dominantAmount =
        dominant.isEmpty ? 0.0 : budget.totalByCategory(dominant);

    final previousMonth = DateTime(selected.year, selected.month - 1, 1);
    final lastMonthSpent = budget.totalSpentForMonth(previousMonth);

    final freeLimit = BudgetProvider.freeMonthlyExpenseLimit;

    /// 🧠 FINANCIAL SCORE
    final score = KikiInsightsService.financialScore(
      budget: budget.monthlyBudget,
      spent: monthSpent,
      expenses: monthExpenses,
    );

    /// 💡 DAILY INSIGHT
    final dailyInsight =
        KikiInsightsService.buildDailyInsight(monthExpenses);

    /// 🏆 ACHIEVEMENTS
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

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            /// 📅 MONTH SELECTOR
            MonthSelector(
              selectedMonth: selected,
              onChanged: budget.setSelectedMonthDate,
            ),

            const SizedBox(height: 16),

            /// 🐱 KIKI MESSAGE
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

            /// 🏆 ACHIEVEMENTS
            if (achievements.isNotEmpty)
              AchievementsCard(
                achievements: achievements,
              ),

            if (achievements.isNotEmpty)
              const SizedBox(height: 16),

            /// 🧠 FINANCIAL SCORE
            if (hasMonthExpenses) ...[
              KikiScoreCard(score: score),
              const SizedBox(height: 16),
            ],

            /// 📊 MONTH OVERVIEW
            if (hasMonthExpenses)
              MonthlyOverviewCard(
                budget: budget.monthlyBudget,
                spent: monthSpent,
                currencySymbol: budget.currencySymbol,
              ),

            if (hasMonthExpenses)
              const SizedBox(height: 16),

            /// 🏷️ DOMINANT CATEGORY
            if (hasMonthExpenses)
              DominantCategoryCard(
                category: dominant,
                amount: dominantAmount,
                currencySymbol: budget.currencySymbol,
              ),

            if (hasMonthExpenses)
              const SizedBox(height: 16),

            /// 💡 DAILY INSIGHT
            if (hasMonthExpenses)
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
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            if (streak >= 2)
              Card(
                child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      "🔥",
                      style: TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "$streak días seguidos registrando gastos",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]
                ),
              ),
            ),

            /// 🔒 PRO FEATURES
            if (budget.isPro) ...[
              CategoryBarChartCard(
                expenses: monthExpenses,
                currencySymbol: budget.currencySymbol,
              ),

              const SizedBox(height: 16),

              const MonthlyTrendChartCard(months: 6),
            ] else
              const LockedProCard(
                title: 'Análisis avanzado',
                subtitle:
                    'Desbloquea tendencias, categorías y coaching financiero.',
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
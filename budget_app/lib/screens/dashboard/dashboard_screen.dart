import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';
import '../../providers/commitments_provider.dart';
import '../../providers/financial_profile_provider.dart';
import '../../design_system/kiki_colors.dart';
import '../../design_system/kiki_spacing.dart';
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
import '../../widgets/monthly_commitments_card.dart';
import '../../widgets/secret_tap_detector.dart';
import '../../utils/kiki_mood_visual.dart';

import '../debug/debug_panel_screen.dart';
import '../expenses/add_expenses_modal.dart';
import '../expenses/expenses_screen.dart';
import '../commitments/commitments_screen.dart';
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
      backgroundColor: KikiColors.background,
      appBar: const _DashAppBar(),
      body: _pages[_index],
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              tooltip: 'Agregar gasto',
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() {
            _index = i;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Gastos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Perfil',
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
        child: const Text('Kiki Finance'),
      ),
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.watch<BudgetProvider>().isPro;
  }

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final commitmentsProvider = context.watch<CommitmentsProvider>();
    final financialProfile = context.watch<FinancialProfileProvider>();

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

    final dailyInsight = KikiInsightsService.buildDailyInsight(monthExpenses);

    final achievements =
        AchievementService.evaluate(budget).where((a) => a.unlocked).toList();

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

    Widget quickAdd(String _, String category) {
      final fixedCategory = category.startsWith('Caf') ? 'Café' : category;
      final icon = switch (fixedCategory) {
        'Café' => Icons.local_cafe_rounded,
        'Comida' => Icons.restaurant_rounded,
        'Transporte' => Icons.directions_car_rounded,
        'Compras' => Icons.shopping_bag_rounded,
        _ => Icons.add_circle_outline_rounded,
      };

      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => AddExpenseModal(prefilledCategory: fixedCategory),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: KikiSpacing.sm,
            horizontal: KikiSpacing.xs,
          ),
          child: Column(
            children: [
              Icon(icon, color: KikiColors.primary, size: 26),
              const SizedBox(height: KikiSpacing.xs),
              Text(
                fixedCategory,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
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

    final moodVisual = KikiMoodVisual.fromBudgetState(
      hasExpenses: hasExpenses,
      budget: budget.monthlyBudget,
      spent: spent,
      achievementsCount: achievements.length,
      streak: streak,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(KikiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MonthSelector(
              selectedMonth: selected,
              onChanged: budget.setSelectedMonthDate,
            ),
            const SizedBox(height: 16),
            KikiMessageCard(
              mood: moodVisual.mood,
              message: insight.message,
              actionLabel: insight.actionLabel,
              avatarId: financialProfile.profile.selectedAvatarId,
              onAction: insight.action == KikiInsightAction.addExpense
                  ? openAddExpense
                  : insight.action == KikiInsightAction.viewExpenses
                      ? openExpenses
                      : null,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    quickAdd('', 'Café'),
                    quickAdd('', 'Comida'),
                    quickAdd('', 'Transporte'),
                    quickAdd('', 'Compras'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final textScale = MediaQuery.textScalerOf(context).scale(1);
                final useHorizontalLayout =
                    constraints.maxWidth >= 680 && textScale <= 1.15;
                final overviewCard = MonthlyOverviewCard(
                  budget: budget.monthlyBudget,
                  spent: spent,
                  currencySymbol: budget.currencySymbol,
                );

                if (!useHorizontalLayout) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      KikiScoreCard(score: score),
                      const SizedBox(height: 12),
                      overviewCard,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: KikiScoreCard(score: score)),
                    const SizedBox(width: 12),
                    Expanded(child: overviewCard),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            MonthlyCommitmentsCard(
              commitments: commitmentsProvider.getCommitmentsForMonth(selected),
              currencySymbol: budget.currencySymbol,
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CommitmentsScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            if (achievements.isNotEmpty) ...[
              AchievementsCard(achievements: achievements),
              const SizedBox(height: 16),
            ],
            if (streak >= 2) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: KikiColors.warning,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text('$streak días seguidos'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (hasExpenses) ...[
              DominantCategoryCard(
                category: dominant,
                amount: dominantAmount,
                currencySymbol: budget.currencySymbol,
              ),
              const SizedBox(height: 16),
            ],
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: budget.isPro
                  ? Column(
                      key: const ValueKey('pro'),
                      children: [
                        CategoryBarChartCard(
                          expenses: monthExpenses,
                          currencySymbol: budget.currencySymbol,
                        ),
                        const SizedBox(height: 16),
                        const MonthlyTrendChartCard(months: 6),
                      ],
                    )
                  : const LockedProCard(
                      key: ValueKey('free'),
                      title: 'Desbloquea Kiki Pro',
                      subtitle: 'Gráficos, tendencias y coaching avanzado.',
                    ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

import 'dart:math';
import '../models/expense.dart';

class KikiInsightResult {
  final String message;
  final String? actionLabel;
  final KikiInsightAction action;

  const KikiInsightResult({
    required this.message,
    this.actionLabel,
    this.action = KikiInsightAction.none,
  });
}

enum KikiInsightAction {
  none,
  addExpense,
  viewExpenses,
  goToCurrentMonth,
  upgradePro,
}

class KikiInsightsService {

  static KikiInsightResult buildInsight({
    required bool isNewMonth,
    required bool isPro,
    required bool isCurrentMonth,
    required bool hasExpenses,
    required int expenseCount,
    required int freeLimit,
    required double monthlyBudget,
    required double totalSpent,
    required String dominantCategory,
    required double dominantAmount,
    required List<Expense> expenses,
    required double lastMonthSpent,
    required DateTime selectedMonth,
  }) {

    final percentUsed =
        monthlyBudget <= 0 ? 0.0 : (totalSpent / monthlyBudget);

    if (isNewMonth) {
      return const KikiInsightResult(
        message: 'Nuevo mes 🗓️ ¿Definimos presupuesto y arrancamos con buen pie?',
        actionLabel: 'Agregar gasto',
        action: KikiInsightAction.addExpense,
      );
    }

    if (!isPro && expenseCount >= freeLimit) {
      return KikiInsightResult(
        message:
            'Llegaste al límite Free de $freeLimit gastos este mes.',
        actionLabel: 'Activar Pro',
        action: KikiInsightAction.upgradePro,
      );
    }

    if (!hasExpenses) {
      if (isCurrentMonth) {
        return const KikiInsightResult(
          message:
              'Este mes está vacío 🐾 Agrega tu primer gasto.',
          actionLabel: 'Agregar gasto',
          action: KikiInsightAction.addExpense,
        );
      }

      return const KikiInsightResult(
        message: 'Este mes no tiene movimientos.',
        actionLabel: 'Ir al mes actual',
        action: KikiInsightAction.goToCurrentMonth,
      );
    }

    if (monthlyBudget <= 0) {
      return const KikiInsightResult(
        message:
            'Ya tienes gastos registrados pero no hay presupuesto definido.',
        actionLabel: 'Ver gastos',
        action: KikiInsightAction.viewExpenses,
      );
    }

    if (percentUsed >= 1.0) {
      return KikiInsightResult(
        message:
            'Te pasaste del presupuesto 😅 Ya llevas ${(percentUsed * 100).toStringAsFixed(0)}%.',
        actionLabel: 'Revisar gastos',
        action: KikiInsightAction.viewExpenses,
      );
    }

    if (percentUsed >= 0.85) {
      return KikiInsightResult(
        message:
            'Ojo 👀 ya consumiste ${(percentUsed * 100).toStringAsFixed(0)}% del presupuesto.',
        actionLabel: 'Revisar gastos',
        action: KikiInsightAction.viewExpenses,
      );
    }

    final streak = expenseStreak(expenses);

    if (streak >= 3) {
      return KikiInsightResult(
        message:
            '🔥 Llevas $streak días seguidos registrando gastos.',
      );
    }

    final recent = _last7DaysTotal(expenses);
    final previous = _previous7DaysTotal(expenses);

    if (recent > previous * 1.35 && previous > 0) {
      return const KikiInsightResult(
        message:
            'Tu ritmo de gasto aumentó bastante en los últimos días 📈',
        actionLabel: 'Revisar gastos',
        action: KikiInsightAction.viewExpenses,
      );
    }

    final projection = projectedMonthlySpend(
      expenses,
      selectedMonth,
    );

    if (projection > monthlyBudget) {
      return KikiInsightResult(
        message:
            'Si sigues así terminarás el mes con ${projection.toStringAsFixed(0)}.',
        actionLabel: 'Revisar gastos',
        action: KikiInsightAction.viewExpenses,
      );
    }

    final score = financialScore(
      budget: monthlyBudget,
      spent: totalSpent,
      expenses: expenses,
    );

    if (score >= 90) {
      return KikiInsightResult(
        message: 'Score financiero: $score/100 🐱 Excelente control.',
      );
    }

    if (score < 60) {
      return KikiInsightResult(
        message: 'Score financiero: $score/100. Conviene revisar gastos.',
        actionLabel: 'Revisar gastos',
        action: KikiInsightAction.viewExpenses,
      );
    }

    return KikiInsightResult(message: randomTip());
  }

  static int expenseStreak(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;

    final dates = expenses
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList();

    dates.sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime current = DateTime.now();

    while (true) {
      final exists = dates.any((d) =>
          d.year == current.year &&
          d.month == current.month &&
          d.day == current.day);

      if (!exists) break;

      streak++;
      current = current.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static double projectedMonthlySpend(
      List<Expense> expenses, DateTime month) {
    if (expenses.isEmpty) return 0;

    final total =
        expenses.fold<double>(0, (sum, e) => sum + e.amount);

    final daysInMonth =
        DateTime(month.year, month.month + 1, 0).day;

    final daysPassed = DateTime.now().day;

    final avgPerDay = total / daysPassed;

    return avgPerDay * daysInMonth;
  }

  static int financialScore({
    required double budget,
    required double spent,
    required List<Expense> expenses,
  }) {
    if (budget <= 0) return 50;

    double score = 100;
    final percent = spent / budget;

    if (percent > 1) score -= 40;
    if (percent > 0.85) score -= 20;
    if (percent > 0.7) score -= 10;

    if (expenses.length > 30) score -= 5;
    if (spent < budget * 0.5) score += 5;

    return score.clamp(0, 100).toInt();
  }

  static double _last7DaysTotal(List<Expense> expenses) {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));

    return expenses
        .where((e) => e.date.isAfter(start))
        .fold<double>(0, (sum, e) => sum + e.amount);
  }

  static double _previous7DaysTotal(List<Expense> expenses) {
    final now = DateTime.now();
    final end = now.subtract(const Duration(days: 7));
    final start = now.subtract(const Duration(days: 14));

    return expenses
        .where((e) => e.date.isAfter(start) && e.date.isBefore(end))
        .fold<double>(0, (sum, e) => sum + e.amount);
  }

  static String randomTip() {
    final tips = [
      'Registrar gastos todos los días mejora mucho el control.',
      'Los pequeños gastos suelen ser los que más se acumulan.',
      'Revisar tus gastos una vez por semana evita sorpresas.',
      'Cada gasto registrado hace a Kiki más inteligente 🐾',
    ];

    return tips[Random().nextInt(tips.length)];
  }

  static String buildDailyInsight(List<Expense> expenses) {
    final today = DateTime.now();

    final todayExpenses = expenses.where((e) =>
      e.date.year == today.year &&
      e.date.month == today.month &&
      e.date.day == today.day);

    final totalToday =
      todayExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);

    if (totalToday == 0) {
      return 'Hoy no registraste gastos 🐾 buen control.';
    }

    if (totalToday < 20) {
      return 'Hoy llevas poco gasto (${totalToday.toStringAsFixed(0)}). Buen ritmo.';
    }

    if (totalToday < 50) {
      return 'Hoy llevas ${totalToday.toStringAsFixed(0)} en gastos.';
    }

    return 'Hoy ya llevas ${totalToday.toStringAsFixed(0)}. Tal vez conviene frenar un poco 👀';
  }

}


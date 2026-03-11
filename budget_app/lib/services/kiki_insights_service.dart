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
    final percentUsed = monthlyBudget <= 0 ? 0.0 : (totalSpent / monthlyBudget);

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
            'Llegaste al límite Free de $freeLimit gastos este mes. Si quieres seguir registrando, toca pasar a Pro ✨',
        actionLabel: 'Activar Pro',
        action: KikiInsightAction.upgradePro,
      );
    }

    if (!hasExpenses) {
      if (isCurrentMonth) {
        return const KikiInsightResult(
          message:
              'Este mes está vacío 🐾 Agrega tu primer gasto para que empiece a ayudarte con insights.',
          actionLabel: 'Agregar gasto',
          action: KikiInsightAction.addExpense,
        );
      }

      return const KikiInsightResult(
        message:
            'Este mes no tiene movimientos. Puedes volver al mes actual o registrar un gasto aquí.',
        actionLabel: 'Ir al mes actual',
        action: KikiInsightAction.goToCurrentMonth,
      );
    }

    if (monthlyBudget <= 0) {
      return const KikiInsightResult(
        message:
            'Ya tienes gastos registrados, pero aún no has definido presupuesto. Si lo haces, podré decirte si vas bien o si te estás pasando 👀',
        actionLabel: 'Ver gastos',
        action: KikiInsightAction.viewExpenses,
      );
    }

    if (percentUsed >= 1.0) {
      return KikiInsightResult(
        message:
            'Nos pasamos del presupuesto 😅 Ya llevas ${(percentUsed * 100).toStringAsFixed(0)}% del total. Lo primero que revisaría es $dominantCategory.',
        actionLabel: 'Revisar gastos',
        action: KikiInsightAction.viewExpenses,
      );
    }

    if (percentUsed >= 0.85) {
      return KikiInsightResult(
        message:
            'Ojo 👀 ya consumiste ${(percentUsed * 100).toStringAsFixed(0)}% del presupuesto. Tu categoría más pesada es $dominantCategory.',
        actionLabel: 'Revisar gastos',
        action: KikiInsightAction.viewExpenses,
      );
    }

    if (dominantCategory.isNotEmpty && dominantAmount > 0) {
      final categoryMsg = categoryInsight(
        dominantCategory,
        dominantAmount,
        monthlyBudget,
      );

      if (categoryMsg.isNotEmpty) {
        return KikiInsightResult(
          message: categoryMsg,
          actionLabel: 'Ver gastos',
          action: KikiInsightAction.viewExpenses,
        );
      }
    }

    final recent = _last7DaysTotal(expenses);
    final previous = _previous7DaysTotal(expenses);

    if (recent > 0 && previous > 0 && recent > previous * 1.35) {
      return const KikiInsightResult(
        message:
            'Tu ritmo de gasto aumentó bastante en los últimos días 📈 Quizá conviene revisar antes de que el mes se ponga pesado.',
        actionLabel: 'Revisar gastos',
        action: KikiInsightAction.viewExpenses,
      );
    }

    final projection = projectedMonthlySpend(
      expenses,
      selectedMonth,
    );

    if (projection > monthlyBudget && monthlyBudget > 0) {
      return KikiInsightResult(
        message:
            'Si mantienes este ritmo terminarás el mes con ${projection.toStringAsFixed(0)} en gastos. Tal vez conviene ajustar algunas categorías.',
        actionLabel: 'Revisar gastos',
        action: KikiInsightAction.viewExpenses,
      );
    }

    if (lastMonthSpent > 0 && totalSpent > 0) {
      final diff = ((totalSpent - lastMonthSpent) / lastMonthSpent) * 100;

      if (diff.abs() >= 15) {
        if (diff > 0) {
          return KikiInsightResult(
            message:
                'Este mes llevas ${diff.toStringAsFixed(0)}% más gasto que el mes pasado.',
            actionLabel: 'Revisar gastos',
            action: KikiInsightAction.viewExpenses,
          );
        } else {
          return KikiInsightResult(
            message:
                '¡Bien! Estás gastando ${diff.abs().toStringAsFixed(0)}% menos que el mes pasado.',
          );
        }
      }
    }

    final score = financialScore(
      budget: monthlyBudget,
      spent: totalSpent,
      expenses: expenses,
    );

    if (score >= 90) {
      return KikiInsightResult(
        message: 'Score financiero del mes: $score/100 🐱 ¡Excelente control!',
      );
    }

    if (score >= 75) {
      return KikiInsightResult(
        message: 'Score financiero del mes: $score/100. Vas bastante bien.',
      );
    }

    if (score < 60) {
      return KikiInsightResult(
        message:
            'Score financiero del mes: $score/100. Quizá conviene revisar algunas categorías.',
        actionLabel: 'Revisar gastos',
        action: KikiInsightAction.viewExpenses,
      );
    }

    if (percentUsed < 0.5) {
      return const KikiInsightResult(
        message:
            '¡Vas muy bien! Tus gastos siguen bajo control y el mes todavía tiene margen 🐾',
        actionLabel: 'Agregar gasto',
        action: KikiInsightAction.addExpense,
      );
    }

    return KikiInsightResult(
      message: randomTip(),
    );
  }

  static String categoryInsight(String category, double amount, double budget) {
    if (budget <= 0) return '';

    final percent = amount / budget;

    if (percent >= 0.45) {
      return '$category representa más del 45% de tu presupuesto. Quizá ahí está tu mayor oportunidad de ahorro.';
    }

    if (percent >= 0.30) {
      return '$category está pesando bastante este mes. Podría valer la pena revisarlo.';
    }

    if (percent >= 0.20) {
      return '$category es una parte importante de tus gastos actuales.';
    }

    return '';
  }

  static String randomTip() {
    final tips = [
      'Registrar gastos todos los días mejora mucho el control financiero 🐾',
      'Los pequeños gastos suelen ser los que más se acumulan.',
      'Revisar tus gastos una vez por semana puede evitar sorpresas.',
      'Si reduces una sola categoría, tu presupuesto mejora rápido.',
      'Cada gasto que registras hace a Kiki más inteligente 😺',
    ];

    final r = Random();
    return tips[r.nextInt(tips.length)];
  }

  static double projectedMonthlySpend(
    List<Expense> expenses,
    DateTime month,
  ) {
    if (expenses.isEmpty) return 0;

    final now = DateTime.now();
    final isCurrentMonth = now.year == month.year && now.month == month.month;

    final effectiveNow = isCurrentMonth
        ? now
        : DateTime(month.year, month.month + 1, 0);

    final startOfMonth = DateTime(month.year, month.month, 1);
    final daysPassed = effectiveNow.difference(startOfMonth).inDays + 1;

    if (daysPassed <= 0) return 0;

    final total = expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
    final avgPerDay = total / daysPassed;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

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

    if (percent > 1) {
      score -= 40;
    } else if (percent > 0.85) {
      score -= 20;
    } else if (percent > 0.70) {
      score -= 10;
    }

    if (expenses.length > 30) {
      score -= 5;
    }

    if (spent < budget * 0.5) {
      score += 5;
    }

    score = score.clamp(0, 100);
    return score.toInt();
  }

  static double _last7DaysTotal(List<Expense> expenses) {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));

    return expenses
        .where((e) => e.date.isAfter(start) && e.date.isBefore(now))
        .fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  static double _previous7DaysTotal(List<Expense> expenses) {
    final now = DateTime.now();
    final end = now.subtract(const Duration(days: 7));
    final start = now.subtract(const Duration(days: 14));

    return expenses
        .where((e) => e.date.isAfter(start) && e.date.isBefore(end))
        .fold<double>(0.0, (sum, e) => sum + e.amount);
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


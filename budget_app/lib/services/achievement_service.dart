import '../models/achievement.dart';
import '../providers/budget_provider.dart';

class AchievementService {

  static List<Achievement> evaluate(BudgetProvider budget) {

    final expenses = budget.allExpenses;

    return [

      Achievement(
        id: "first_expense",
        title: "Primer gasto",
        description: "Registraste tu primer gasto 🐾",
        unlocked: expenses.isNotEmpty,
      ),

      Achievement(
        id: "10_expenses",
        title: "Organizado",
        description: "Registraste 10 gastos",
        unlocked: expenses.length >= 10,
      ),

      Achievement(
        id: "under_budget",
        title: "Buen control",
        description: "Mes bajo presupuesto",
        unlocked: budget.currentMonthTotalSpent <= budget.monthlyBudget &&
            budget.monthlyBudget > 0,
      ),

    ];
  }
}

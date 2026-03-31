class FinancialHealthEngine {

  static int calculateScore({
    required double spent,
    required double budget,
    required int expenseCount,
  }) {

    int score = 0;

    /// Presupuesto
    if (budget > 0) {
      final ratio = spent / budget;

      if (ratio <= 0.8) {
        score += 40;
      } else if (ratio <= 1) score += 25;
      else score += 10;
    }

    /// Consistencia
    if (expenseCount >= 20) {
      score += 20;
    } else if (expenseCount >= 10) {
      score += 10;
    }

    /// Uso de la app
    if (expenseCount > 0) {
      score += 20;
    }

    /// Bonus control
    if (spent < budget) {
      score += 20;
    }

    return score.clamp(0, 100);
  }
}
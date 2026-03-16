import '../models/expense.dart';

class StreakService {

  static int calculateStreak(List<Expense> expenses) {

    if (expenses.isEmpty) return 0;

    final dates = expenses
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList()
      ..sort((a,b) => b.compareTo(a));

    int streak = 1;

    for (int i = 1; i < dates.length; i++) {

      final diff = dates[i - 1].difference(dates[i]).inDays;

      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
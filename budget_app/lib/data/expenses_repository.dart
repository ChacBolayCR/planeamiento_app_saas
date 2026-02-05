import '../models/expense.dart';

class ExpensesRepository {
  ExpensesRepository._();
  static final ExpensesRepository instance = ExpensesRepository._();

  final List<Expense> _expenses = [];

  List<Expense> get expenses => List.unmodifiable(_expenses);

  void addExpense(Expense expense) {
    _expenses.add(expense);
  }

  double get totalExpenses {
    return _expenses.fold(0, (sum, e) => sum + e.amount);
  }

  Map<String, double> expensesByCategory() {
    final Map<String, double> data = {};
    for (final e in _expenses) {
      data[e.category] = (data[e.category] ?? 0) + e.amount;
    }
    return data;
  }
}

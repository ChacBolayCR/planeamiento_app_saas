import '../models/expense.dart';

class ExpensesRepository {
  ExpensesRepository._internal();
  static final ExpensesRepository instance = ExpensesRepository._internal();

  final List<Expense> _expenses = [];

  List<Expense> get expenses => List.unmodifiable(_expenses);

  void addExpense(Expense expense) {
    _expenses.add(expense);
  }

  double get totalExpenses {
    return _expenses.fold(0, (sum, e) => sum + e.amount);
  }
}

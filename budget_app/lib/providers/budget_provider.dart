import 'package:flutter/material.dart';
import '../models/expense.dart';

class BudgetProvider extends ChangeNotifier {
  double _monthlyBudget = 2000;
  final List<Expense> _expenses = [];

  BudgetProvider() {
    debugPrint('🔥 BudgetProvider creado: ${hashCode}');
  }

  double get monthlyBudget => _monthlyBudget;
  List<Expense> get expenses => List.unmodifiable(_expenses);

  double get totalExpenses =>
      _expenses.fold(0, (sum, e) => sum + e.amount);

  double get remainingBudget =>
      _monthlyBudget - totalExpenses;

  void setMonthlyBudget(double value) {
    _monthlyBudget = value;
    notifyListeners();
  }

  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  void removeExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}

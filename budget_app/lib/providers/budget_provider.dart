import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';

class BudgetProvider extends ChangeNotifier {
  static const _budgetKey = 'monthly_budget';
  static const _expensesKey = 'expenses_list';

  double _monthlyBudget = 2000;
  final List<Expense> _expenses = [];

  double get monthlyBudget => _monthlyBudget;
  List<Expense> get expenses => List.unmodifiable(_expenses);

  double get totalExpenses =>
      _expenses.fold(0, (sum, e) => sum + e.amount);

  double get remainingBudget =>
      _monthlyBudget - totalExpenses;

  BudgetProvider() {
    _loadData();
  }

  // ---------- Persistence ----------

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _monthlyBudget = prefs.getDouble(_budgetKey) ?? 2000;

    final expensesJson = prefs.getString(_expensesKey);
    if (expensesJson != null) {
      final List decoded = jsonDecode(expensesJson);
      _expenses
        ..clear()
        ..addAll(decoded.map((e) => Expense.fromJson(e)));
    }

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble(_budgetKey, _monthlyBudget);
    await prefs.setString(
      _expensesKey,
      jsonEncode(_expenses.map((e) => e.toJson()).toList()),
    );
  }

  // ---------- Actions ----------

  void setMonthlyBudget(double value) {
    _monthlyBudget = value;
    _saveData();
    notifyListeners();
  }

  void addExpense(Expense expense) {
    _expenses.add(expense);
    _saveData();
    notifyListeners();
  }

  void removeExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    _saveData();
    notifyListeners();
  }
}

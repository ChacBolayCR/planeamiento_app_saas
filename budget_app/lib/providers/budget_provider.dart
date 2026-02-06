import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';

class BudgetProvider extends ChangeNotifier {
  // =====================
  // ESTADO
  // =====================
  double _monthlyBudget = 2000;
  final List<Expense> _expenses = [];

  String _currencyCode = 'USD';

  final Map<String, String> _currencySymbols = {
    'USD': '\$',
    'CRC': '₡',
    'EUR': '€',
    'MXN': '\$',
  };

  // =====================
  // KEYS STORAGE
  // =====================
  static const _budgetKey = 'monthly_budget';
  static const _currencyKey = 'currency_code';
  static const _expensesKey = 'expenses';

  // =====================
  // GETTERS
  // =====================
  double get monthlyBudget => _monthlyBudget;
  List<Expense> get expenses => List.unmodifiable(_expenses);

  String get currencyCode => _currencyCode;
  String get currencySymbol =>
      _currencySymbols[_currencyCode] ?? '\$';

  double get totalExpenses =>
      _expenses.fold(0, (sum, e) => sum + e.amount);

  double get remainingBudget =>
      _monthlyBudget - totalExpenses;

  // =====================
  // INIT / LOAD
  // =====================
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _monthlyBudget = prefs.getDouble(_budgetKey) ?? 2000;
    _currencyCode = prefs.getString(_currencyKey) ?? 'USD';

    final expensesJson = prefs.getStringList(_expensesKey);
    if (expensesJson != null) {
      _expenses
        ..clear()
        ..addAll(
          expensesJson
              .map((e) => Expense.fromMap(jsonDecode(e)))
              .toList(),
        );
    }

    notifyListeners();
  }

  // =====================
  // SAVE
  // =====================
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble(_budgetKey, _monthlyBudget);
    await prefs.setString(_currencyKey, _currencyCode);

    final expensesJson =
        _expenses.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(_expensesKey, expensesJson);
  }

  // =====================
  // SETTERS
  // =====================
  void setMonthlyBudget(double value) {
    _monthlyBudget = value;
    _saveData();
    notifyListeners();
  }

  void setCurrency(String code) {
    if (_currencySymbols.containsKey(code)) {
      _currencyCode = code;
      _saveData();
      notifyListeners();
    }
  }

  // =====================
  // EXPENSES
  // =====================
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

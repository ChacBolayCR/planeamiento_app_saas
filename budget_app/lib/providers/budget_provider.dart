import 'package:flutter/material.dart';
import '../models/expense.dart';

class BudgetProvider extends ChangeNotifier {
  /// 💰 Presupuesto mensual
  double _monthlyBudget = 1000;
  double get monthlyBudget => _monthlyBudget;

  /// 💱 Moneda
  String _currencyCode = 'CRC';
  String get currencyCode => _currencyCode;

  String get currencySymbol =>
      _currencyCode == 'USD' ? '\$' : '₡';

  /// 📦 Gastos
  final List<Expense> _expenses = [];
  List<Expense> get expenses => List.unmodifiable(_expenses);

  /// =======================
  /// CONFIGURACIÓN
  /// =======================
  void setMonthlyBudget(double value) {
    _monthlyBudget = value;
    notifyListeners();
  }

  void setCurrency(String code) {
    _currencyCode = code;
    notifyListeners();
  }

  /// =======================
  /// GESTIÓN DE GASTOS
  /// =======================
  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  void removeExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  /// =======================
  /// CÁLCULOS
  /// =======================
  double get totalSpent {
    return _expenses.fold(0, (sum, e) => sum + e.amount);
  }

  double totalByCategory(String category) {
    return _expenses
        .where((e) => e.category == category)
        .fold(0, (sum, e) => sum + e.amount);
  }

  /// Para barras de progreso
  double categoryPercent(String category) {
    if (_monthlyBudget <= 0) return 0;
    final total = totalByCategory(category);
    return (total / _monthlyBudget).clamp(0.0, 1.0);
  }

  /// Para Kiki 🐱
  String getDominantCategory() {
    final Map<String, double> totals = {};

    for (final e in _expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }

    if (totals.isEmpty) return '';

    return totals.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}

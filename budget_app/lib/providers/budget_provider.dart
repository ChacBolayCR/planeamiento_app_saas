import 'package:flutter/material.dart';
import '../models/expense.dart';

String monthKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

class BudgetProvider extends ChangeNotifier {
  /// 💰 Presupuesto mensual
  double _monthlyBudget = 1000;
  double get monthlyBudget => _monthlyBudget;

  /// 💱 Moneda
  String _currencyCode = 'CRC';
  String get currencyCode => _currencyCode;

  String get currencySymbol => _currencyCode == 'USD' ? '\$' : '₡';

  /// 📦 Gastos
  final List<Expense> _expenses = [];
  List<Expense> get expenses => List.unmodifiable(_expenses);

  /// =======================
  /// NUEVO MES
  /// =======================
  String? _lastMonthKey;
  bool _isNewMonth = false;
  bool get isNewMonth => _isNewMonth;

  /// Llamar al abrir Dashboard (una vez por sesión/visita)
  void checkNewMonth() {
    final nowKey = monthKey(DateTime.now());

    if (_lastMonthKey != null && _lastMonthKey != nowKey) {
      _isNewMonth = true;
    } else {
      _isNewMonth = false;
    }

    _lastMonthKey = nowKey;
    // No notifico aquí para evitar rebuilds raros;
    // el dashboard solo lo lee para armar el mensaje.
  }

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
    return _expenses.where((e) => e.category == category).fold(0, (sum, e) => sum + e.amount);
  }

  double categoryPercent(String category) {
    if (_monthlyBudget <= 0) return 0;
    final total = totalByCategory(category);
    return (total / _monthlyBudget).clamp(0.0, 1.0);
  }

  String getDominantCategory() {
    final Map<String, double> totals = {};
    for (final e in _expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    if (totals.isEmpty) return '';
    return totals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

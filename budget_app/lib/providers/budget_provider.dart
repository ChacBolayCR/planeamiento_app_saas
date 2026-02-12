import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  /// 📅 Mes seleccionado (por defecto: actual)
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime get selectedMonth => _selectedMonth;

  void setSelectedMonth(DateTime value) {
    _selectedMonth = DateTime(value.year, value.month, 1);
    notifyListeners();
  }

  /// 📦 Gastos (guardados todos juntos; filtramos por fecha)
  final List<Expense> _expenses = [];
  List<Expense> get expenses => List.unmodifiable(_expenses);

  /// =======================
  /// NUEVO MES (persistente)
  /// =======================
  static const _prefLastMonthKey = 'last_month_key';
  bool _isNewMonth = false;
  bool get isNewMonth => _isNewMonth;

  /// Llamar una vez en Splash
  Future<void> initMonthTracking() async {
    final prefs = await SharedPreferences.getInstance();
    final nowKey = monthKey(DateTime.now());
    final last = prefs.getString(_prefLastMonthKey);

    _isNewMonth = (last != null && last != nowKey);

    await prefs.setString(_prefLastMonthKey, nowKey);
    notifyListeners();
  }

  /// Si quieres “marcar como visto” y que no siga saliendo:
  void dismissNewMonth() {
    if (!_isNewMonth) return;
    _isNewMonth = false;
    notifyListeners();
  }

  /// =======================
  /// GETTERS POR MES
  /// =======================
  List<Expense> get currentMonthExpenses {
    final key = monthKey(_selectedMonth);
    return _expenses.where((e) => monthKey(e.date) == key).toList();
  }

  double get currentMonthTotalSpent {
    return currentMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  String get currentMonthDominantCategory {
    final Map<String, double> totals = {};
    for (final e in currentMonthExpenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    if (totals.isEmpty) return '';
    return totals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
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
  /// CÁLCULOS GENERALES (todos los meses)
  /// =======================
  double get totalSpent {
    return _expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  double totalByCategory(String category) {
    return _expenses
        .where((e) => e.category == category)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double categoryPercent(String category) {
    if (_monthlyBudget <= 0) return 0.0;
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

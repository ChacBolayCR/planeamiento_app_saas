import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';

String monthKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

class BudgetProvider extends ChangeNotifier {
  // ====== prefs keys
  static const _kBudget = 'monthlyBudget';
  static const _kCurrency = 'currencyCode';
  static const _kSelectedMonth = 'selectedMonthKey';
  static const _kLastSeenMonth = 'lastSeenMonthKey';
  static const _kDismissedMonth = 'dismissedNewMonthKey'; // para no repetir el mensaje
  static String _kExpensesFor(String mk) => 'expenses_$mk';

  SharedPreferences? _prefs;

  /// 💰 Presupuesto mensual
  double _monthlyBudget = 0;
  double get monthlyBudget => _monthlyBudget;

  /// 💱 Moneda
  String _currencyCode = 'CRC';
  String get currencyCode => _currencyCode;
  String get currencySymbol => _currencyCode == 'USD' ? '\$' : '₡';

  /// 📅 Mes seleccionado (clave YYYY-MM)
  late String _selectedMonthKey;
  String get selectedMonth => _selectedMonthKey;

  /// 🆕 Nuevo mes
  bool _isNewMonth = false;
  bool get isNewMonth => _isNewMonth;

  /// 📦 Cache en memoria de gastos por mes
  /// (para no estar leyendo prefs cada build)
  final Map<String, List<Expense>> _expensesByMonth = {};

  // =======================
  // INIT (llamar 1 vez al inicio: Splash o MyApp)
  // =======================
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();

    // selected month por default = mes actual
    final nowKey = monthKey(DateTime.now());
    _selectedMonthKey = _prefs!.getString(_kSelectedMonth) ?? nowKey;

    // budget/currency
    _monthlyBudget = _prefs!.getDouble(_kBudget) ?? 0;
    _currencyCode = _prefs!.getString(_kCurrency) ?? 'CRC';

    // cargar gastos del mes seleccionado (y opcionalmente del actual)
    await _loadMonthIfNeeded(_selectedMonthKey);
    if (_selectedMonthKey != nowKey) {
      await _loadMonthIfNeeded(nowKey);
    }

    // marcar nuevo mes si aplica
    _checkNewMonthInternal();

    notifyListeners();
  }

  // =======================
  // MES
  // =======================
  void setSelectedMonth(String monthKey) {
    _selectedMonthKey = monthKey;
    _prefs?.setString(_kSelectedMonth, monthKey);
    _loadMonthIfNeeded(monthKey); // async fire-and-forget
    notifyListeners();
  }

  DateTime get selectedMonthDate {
    final parts = _selectedMonthKey.split('-'); // YYYY-MM
    final y = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    return DateTime(y, m, 1);
  }

void setSelectedMonthDate(DateTime date) {
  final mk = monthKey(date);
  setSelectedMonth(mk);
}


  // =======================
  // CONFIG
  // =======================
  void setMonthlyBudget(double value) {
    _monthlyBudget = value;
    _prefs?.setDouble(_kBudget, value);
    notifyListeners();
  }

  void setCurrency(String code) {
    _currencyCode = code;
    _prefs?.setString(_kCurrency, code);
    notifyListeners();
  }

  // =======================
  // GASTOS (por mes seleccionado)
  // =======================
  List<Expense> get currentMonthExpenses =>
      List.unmodifiable(_expensesByMonth[_selectedMonthKey] ?? const []);

  double get currentMonthTotalSpent =>
      currentMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);

  String get currentMonthDominantCategory {
    final totals = <String, double>{};
    for (final e in currentMonthExpenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    if (totals.isEmpty) return '';
    return totals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Backward-compat (si alguna pantalla aún usa budget.expenses / totalSpent)
  List<Expense> get expenses => currentMonthExpenses;
  double get totalSpent => currentMonthTotalSpent;

  void addExpense(Expense expense) {
    final list = _expensesByMonth.putIfAbsent(_selectedMonthKey, () => []);
    list.add(expense);
    _saveMonth(_selectedMonthKey);
    notifyListeners();
  }

  void removeExpense(String id) {
    final list = _expensesByMonth[_selectedMonthKey];
    if (list == null) return;
    list.removeWhere((e) => e.id == id);
    _saveMonth(_selectedMonthKey);
    notifyListeners();
  }

  // =======================
  // CÁLCULOS
  // =======================
  double totalByCategory(String category) {
    return currentMonthExpenses
        .where((e) => e.category == category)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double categoryPercent(String category) {
    if (_monthlyBudget <= 0) return 0;
    final total = totalByCategory(category);
    return (total / _monthlyBudget).clamp(0.0, 1.0);
  }

  // =======================
  // NUEVO MES (Kiki)
  // =======================
  void checkNewMonth() {
    // Llama esto al entrar al dashboard si quieres (opcional)
    _checkNewMonthInternal();
    notifyListeners();
  }

  void dismissNewMonthMessage() {
    // marca “ya vi el mensaje” para este mes actual
    final nowKey = monthKey(DateTime.now());
    _prefs?.setString(_kDismissedMonth, nowKey);
    _isNewMonth = false;
    notifyListeners();
  }

  void _checkNewMonthInternal() {
    final nowKey = monthKey(DateTime.now());
    final lastSeen = _prefs?.getString(_kLastSeenMonth);
    final dismissedFor = _prefs?.getString(_kDismissedMonth);

    // nuevo mes si: ya había un lastSeen distinto al nowKey
    final changed = (lastSeen != null && lastSeen != nowKey);

    // si ya lo descarté para este mes, no mostrar
    final alreadyDismissed = dismissedFor == nowKey;

    _isNewMonth = changed && !alreadyDismissed;

    // actualizar last seen al mes actual (para próximas entradas)
    _prefs?.setString(_kLastSeenMonth, nowKey);
  }

  // =======================
  // PERSISTENCIA
  // =======================
  Future<void> _loadMonthIfNeeded(String mk) async {
    if (_expensesByMonth.containsKey(mk)) return;
    await _loadMonth(mk);
  }

  Future<void> _loadMonth(String mk) async {
    if (_prefs == null) return;

    final raw = _prefs!.getString(_kExpensesFor(mk));
    if (raw == null || raw.isEmpty) {
      _expensesByMonth[mk] = [];
      return;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      _expensesByMonth[mk] = [];
      return;
    }

    _expensesByMonth[mk] = decoded
        .whereType<Map>()
        .map((m) => Expense.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  void _saveMonth(String mk) {
    if (_prefs == null) return;
    final list = _expensesByMonth[mk] ?? [];
    final payload = jsonEncode(list.map((e) => e.toMap()).toList());
    _prefs!.setString(_kExpensesFor(mk), payload);
  }
}

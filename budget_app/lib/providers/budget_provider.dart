import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';

String monthKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}';

class BudgetProvider extends ChangeNotifier {

  /// ===== FREE CONFIG =====
  static const int freeMonthlyExpenseLimit = 25;

  /// ===== TRIAL CONFIG =====
  static const _kTrialStart = 'proTrialStart';
  static const int trialDays = 7;

  /// ===== PREF KEYS =====
  static const _kBudget = 'monthlyBudget';
  static const _kCurrency = 'currencyCode';
  static const _kSelectedMonth = 'selectedMonthKey';
  static const _kLastSeenMonth = 'lastSeenMonthKey';
  static const _kDismissedMonth = 'dismissedNewMonthKey';
  static const _kIsPro = 'isPro';

  static String _kExpensesFor(String mk) => 'expenses_$mk';

  SharedPreferences? _prefs;

  /// ===== USER SETTINGS =====
  double _monthlyBudget = 0;
  double get monthlyBudget => _monthlyBudget;

  String _currencyCode = 'CRC';
  String get currencyCode => _currencyCode;

  String get currencySymbol => _currencyCode == 'USD' ? '\$' : '₡';

  /// ===== PRO =====
  bool _isPro = false;
  bool get isPro => _isPro;

  /// ===== MONTH =====
  String _selectedMonthKey =
      "${DateTime.now().year}-${DateTime.now().month}";

  String get selectedMonth => _selectedMonthKey;

  DateTime get selectedMonthDate {
    try {
      final parts = _selectedMonthKey.split('-');

      if (parts.length != 2) return DateTime.now();

      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        1,
      );
    } catch (_) {
      return DateTime.now();
    }
  }

  /// ===== NEW MONTH =====
  bool _isNewMonth = false;
  bool get isNewMonth => _isNewMonth;

  /// ===== CACHE =====
  final Map<String, List<Expense>> _expensesByMonth = {};

  /// ==========================
  /// INIT
  /// ==========================
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();

    final nowKey = monthKey(DateTime.now());

    _selectedMonthKey = _prefs!.getString(_kSelectedMonth) ?? nowKey;
    _monthlyBudget = _prefs!.getDouble(_kBudget) ?? 0;
    _currencyCode = _prefs!.getString(_kCurrency) ?? 'CRC';
    _isPro = _prefs!.getBool(_kIsPro) ?? false;

    /// ===== TRIAL CHECK =====
    final trialStartString = _prefs!.getString(_kTrialStart);

    if (trialStartString != null) {
      final trialStart = DateTime.tryParse(trialStartString);

      if (trialStart != null) {
        final daysUsed = DateTime.now().difference(trialStart).inDays;

        if (daysUsed >= trialDays) {
          _isPro = false;
          await _prefs!.remove(_kTrialStart);
          await _prefs!.setBool(_kIsPro, false);
        } else {
          _isPro = true;
        }
      }
    }

    await _loadMonthIfNeeded(_selectedMonthKey);

    if (_selectedMonthKey != nowKey) {
      await _loadMonthIfNeeded(nowKey);
    }

    _checkNewMonthInternal();

    notifyListeners();
  }

  /// ==========================
  /// PRO / TRIAL
  /// ==========================

  bool get isTrialActive {
    final trialStartString = _prefs?.getString(_kTrialStart);
    if (trialStartString == null) return false;

    final trialStart = DateTime.tryParse(trialStartString);
    if (trialStart == null) return false;

    final daysUsed = DateTime.now().difference(trialStart).inDays;

    return daysUsed < trialDays;
  }

  int get trialDaysLeft {
    final trialStartString = _prefs?.getString(_kTrialStart);
    if (trialStartString == null) return 0;

    final trialStart = DateTime.tryParse(trialStartString);
    if (trialStart == null) return 0;

    final daysUsed = DateTime.now().difference(trialStart).inDays;

    final left = trialDays - daysUsed;

    return left < 0 ? 0 : left;
  }

  Future<void> startProTrial() async {
    _prefs ??= await SharedPreferences.getInstance();

    final now = DateTime.now();

    await _prefs!.setString(_kTrialStart, now.toIso8601String());
    await _prefs!.setBool(_kIsPro, true);

    _isPro = true;

    notifyListeners();
  }

  Future<void> setIsPro(bool value) async {
    _prefs ??= await SharedPreferences.getInstance();

    _isPro = value;

    await _prefs!.setBool(_kIsPro, value);

    notifyListeners();
  }

  /// 🔥 Para pruebas en web
  Future<void> unlockProForTesting() async {
    await setIsPro(true);
  }

  /// ==========================
  /// FREE LIMIT
  /// ==========================

  bool get isFreeLimitReached {
    if (_isPro) return false;
    return currentMonthExpenses.length >= freeMonthlyExpenseLimit;
  }

  /// ==========================
  /// MONTH
  /// ==========================

  Future<void> setSelectedMonth(String mk) async {
    _selectedMonthKey = mk;
    _prefs?.setString(_kSelectedMonth, mk);

    await _loadMonthIfNeeded(mk);

    notifyListeners();
  }

  void setSelectedMonthDate(DateTime date) {
    setSelectedMonth(monthKey(date));
  }

  /// ==========================
  /// SETTINGS
  /// ==========================

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

  /// ==========================
  /// EXPENSES
  /// ==========================

  List<Expense> get currentMonthExpenses =>
      List.unmodifiable(_expensesByMonth[_selectedMonthKey] ?? const []);

  List<Expense> get expenses => currentMonthExpenses;

  List<Expense> get allExpenses {
    return _expensesByMonth.values
        .expand((month) => month)
        .toList();
  }

  double get currentMonthTotalSpent =>
      currentMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);

  String get currentMonthDominantCategory {
    final totals = <String, double>{};

    for (final e in currentMonthExpenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }

    if (totals.isEmpty) return '';

    return totals.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  void addExpense(Expense expense) {
    if (!_isPro && isFreeLimitReached) return;

    final list = _expensesByMonth.putIfAbsent(
      _selectedMonthKey,
      () => [],
    );

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

  /// ==========================
  /// CALCULATIONS
  /// ==========================

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

  double totalSpentForMonth(DateTime month) {
    final mk = monthKey(DateTime(month.year, month.month, 1));

    if (!_expensesByMonth.containsKey(mk)) {
      _loadMonthIfNeeded(mk);
    }

    final list = _expensesByMonth[mk] ?? const <Expense>[];

    return list.fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  /// ==========================
  /// NEW MONTH
  /// ==========================

  void checkNewMonth() {
    _checkNewMonthInternal();
    notifyListeners();
  }

  void dismissNewMonthMessage() {
    final nowKey = monthKey(DateTime.now());

    _prefs?.setString(_kDismissedMonth, nowKey);

    _isNewMonth = false;

    notifyListeners();
  }

  void _checkNewMonthInternal() {
    final nowKey = monthKey(DateTime.now());

    final lastSeen = _prefs?.getString(_kLastSeenMonth);
    final dismissedFor = _prefs?.getString(_kDismissedMonth);

    final changed = (lastSeen != null && lastSeen != nowKey);
    final alreadyDismissed = dismissedFor == nowKey;

    _isNewMonth = changed && !alreadyDismissed;

    _prefs?.setString(_kLastSeenMonth, nowKey);
  }

  // ==========================
// 🛒 PURCHASES (WEB MOCK)
// ==========================

Future<void> initPurchases() async {
  /// En web no hacemos nada todavía
  /// Luego aquí conectamos in_app_purchase
}

Future<void> buyPro() async {
  /// Simula compra exitosa
  await startProTrial(); // 👈 usa el trial como compra temporal

  // Si quieres que sea permanente en vez de trial:
  // await setIsPro(true);
}

Future<void> restorePurchases() async {
  _prefs ??= await SharedPreferences.getInstance();

  final isProSaved = _prefs!.getBool(_kIsPro) ?? false;

  _isPro = isProSaved;

  notifyListeners();
}

  /// ==========================
  /// PERSISTENCE
  /// ==========================

  Future<void> _loadMonthIfNeeded(String mk) async {
    if (_expensesByMonth.containsKey(mk)) return;
    await _loadMonth(mk);
  }

  Future<void> _loadMonth(String mk) async {
    final raw = _prefs?.getString(_kExpensesFor(mk));

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

    final payload =
        jsonEncode(list.map((e) => e.toMap()).toList());

    _prefs!.setString(_kExpensesFor(mk), payload);
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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

  /// ===== IN-APP PURCHASE =====
  final InAppPurchase _iap = InAppPurchase.instance;

  /// ===== USER SETTINGS =====
  double _monthlyBudget = 0;
  double get monthlyBudget => _monthlyBudget;

  String _currencyCode = 'CRC';
  String get currencyCode => _currencyCode;

  String get currencySymbol => _currencyCode == 'USD' ? '\$' : '₡';

  /// ===== PRO STATE (NEW STRUCTURE) =====
  bool _isProLocal = false;
  bool _hasActiveSubscription = false;

  bool get isPro => _isProLocal || _hasActiveSubscription;

  /// ===== PRODUCTS =====
  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  bool _isStoreLoaded = false;
  bool get isStoreLoaded => _isStoreLoaded;

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

    _isProLocal = _prefs!.getBool(_kIsPro) ?? false;

    /// TRIAL CHECK
    final trialStartString = _prefs!.getString(_kTrialStart);

    if (trialStartString != null) {
      final trialStart = DateTime.tryParse(trialStartString);

      if (trialStart != null) {
        final daysUsed = DateTime.now().difference(trialStart).inDays;

        if (daysUsed >= trialDays) {
          _isProLocal = false;
          await _prefs!.remove(_kTrialStart);
          await _prefs!.setBool(_kIsPro, false);
        } else {
          _isProLocal = true;
        }
      }
    }

    await _loadMonthIfNeeded(_selectedMonthKey);

    if (_selectedMonthKey != nowKey) {
      await _loadMonthIfNeeded(nowKey);
    }

    _checkNewMonthInternal();

    /// 🔥 RESTORE (preparado)
    await restorePurchases();

    notifyListeners();
  }

  /// ==========================
  /// STORE
  /// ==========================
  Future<void> loadProducts() async {
    const ids = {'kiki_pro_monthly'};

    final response = await _iap.queryProductDetails(ids);

    _products = response.productDetails;
    _isStoreLoaded = true;

    notifyListeners();
  }

  Future<void> buyPro() async {
    if (_products.isEmpty) return;

    final product = _products.first;

    final purchaseParam = PurchaseParam(productDetails: product);

    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// ==========================
  /// PURCHASE LISTENER
  /// ==========================
  void initPurchases() {
    _iap.purchaseStream.listen((purchases) {
      for (final purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased) {
          activateProFromPurchase();
        }

        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
      }
    });
  }

  Future<void> activateProFromPurchase() async {
    _hasActiveSubscription = true;
    notifyListeners();
  }

  Future<void> restorePurchases() async {
    /// 🔜 aquí luego conectamos Google Play
    _hasActiveSubscription = false;

    notifyListeners();
  }

  /// ==========================
  /// TRIAL
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

    _isProLocal = true;

    notifyListeners();
  }

  void setIsPro(bool value) {
    _isProLocal = value;
    _prefs?.setBool(_kIsPro, value);
    notifyListeners();
  }

  /// ==========================
  /// FREE LIMIT
  /// ==========================
  bool get isFreeLimitReached {
    if (isPro) return false;
    return currentMonthExpenses.length >= freeMonthlyExpenseLimit;
  }

  /// ==========================
  /// MONTH
  /// ==========================
  void setSelectedMonth(String mk) {
    _selectedMonthKey = mk;
    _prefs?.setString(_kSelectedMonth, mk);

    _loadMonthIfNeeded(mk);

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

  double get currentMonthTotalSpent =>
      currentMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);

  void addExpense(Expense expense) {
    if (!isPro && isFreeLimitReached) return;

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
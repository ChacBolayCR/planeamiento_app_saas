import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';
import '../models/financial_commitment.dart';
import '../providers/budget_provider.dart';
import '../services/category_catalog.dart';

class CommitmentsProvider extends ChangeNotifier {
  static const _commitmentsKey = 'financialCommitments';

  SharedPreferences? _prefs;
  final List<FinancialCommitment> _commitments = [];

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _load();
    notifyListeners();
  }

  List<FinancialCommitment> get commitments => List.unmodifiable(_commitments);

  List<FinancialCommitment> getActiveCommitments() {
    return _commitments.where((commitment) => commitment.isActive).toList();
  }

  List<FinancialCommitment> getCompletedCommitments() {
    return _commitments.where((commitment) => !commitment.isActive).toList();
  }

  List<FinancialCommitment> getCommitmentsForMonth(DateTime month) {
    return getActiveCommitments()
        .where(
          (commitment) =>
              commitment.nextPaymentDate.year == month.year &&
              commitment.nextPaymentDate.month == month.month,
        )
        .toList();
  }

  double totalMonthlyCommitments() {
    return getActiveCommitments()
        .fold(0.0, (sum, commitment) => sum + commitment.monthlyAmount);
  }

  double remainingBalanceForCommitment(String id) {
    return _commitments
        .firstWhere(
          (commitment) => commitment.id == id,
          orElse: () => FinancialCommitment(
            id: 'empty',
            name: 'Compromiso',
            categoryId: CategoryCatalog.loanCategoryId,
            subcategoryId: 'other',
            monthlyAmount: 1,
            totalAmount: 1,
            paidAmount: 0,
            startDate: DateTime.now(),
            nextPaymentDate: DateTime.now(),
            paymentDay: DateTime.now().day,
            totalInstallments: 1,
            paidInstallments: 0,
          ),
        )
        .remainingBalance;
  }

  Future<void> addCommitment(FinancialCommitment commitment) async {
    _commitments.add(commitment);
    await _save();
    notifyListeners();
  }

  Future<void> updateCommitment(FinancialCommitment commitment) async {
    final index = _commitments.indexWhere((item) => item.id == commitment.id);
    if (index < 0) return;

    _commitments[index] = commitment;
    await _save();
    notifyListeners();
  }

  Future<bool> markPaymentAsPaid({
    required String commitmentId,
    required BudgetProvider budgetProvider,
  }) async {
    final index = _commitments.indexWhere((item) => item.id == commitmentId);
    if (index < 0) return false;

    final commitment = _commitments[index];
    final paymentKey = BudgetProvider.monthKeyFor(DateTime.now());
    if (commitment.paidPaymentKeys.contains(paymentKey)) return false;
    if (budgetProvider.isFreeLimitReached) return false;

    final nextPaidAmount = commitment.paidAmount + commitment.monthlyAmount;
    final nextPaidInstallments = (commitment.paidInstallments + 1)
        .clamp(0, commitment.totalInstallments);
    final nextBalance =
        (commitment.totalAmount - nextPaidAmount).clamp(0.0, double.infinity);
    final nextDate =
        _nextMonthlyDate(commitment.nextPaymentDate, commitment.paymentDay);
    final isActive =
        nextBalance > 0 && nextPaidInstallments < commitment.totalInstallments;

    final expense = Expense(
      title: commitment.name,
      category: 'Préstamos',
      categoryId: commitment.categoryId,
      categoryName: 'Préstamos',
      subcategoryId: commitment.subcategoryId,
      amount: commitment.monthlyAmount,
      date: DateTime.now(),
      commitmentId: commitment.id,
      isRecurring: true,
    );

    final added = budgetProvider.addExpense(expense);
    if (!added) return false;

    _commitments[index] = commitment.copyWith(
      paidAmount: nextPaidAmount,
      remainingBalance: nextBalance,
      paidInstallments: nextPaidInstallments,
      nextPaymentDate: nextDate,
      isActive: isActive,
      paidPaymentKeys: [
        ...commitment.paidPaymentKeys,
        paymentKey,
      ],
    );

    await _save();
    notifyListeners();
    return true;
  }

  void _load() {
    _commitments.clear();
    final raw = _prefs?.getString(_commitmentsKey);
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw);
    if (decoded is! List) return;

    _commitments.addAll(
      decoded.whereType<Map>().map(
          (map) => FinancialCommitment.fromMap(Map<String, dynamic>.from(map))),
    );
  }

  Future<void> _save() async {
    await _prefs?.setString(
      _commitmentsKey,
      jsonEncode(_commitments.map((commitment) => commitment.toMap()).toList()),
    );
  }

  DateTime _nextMonthlyDate(DateTime date, int paymentDay) {
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    final lastDay = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
    return DateTime(
        nextMonth.year, nextMonth.month, paymentDay.clamp(1, lastDay));
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/financial_profile.dart';

class FinancialProfileProvider extends ChangeNotifier {
  static const profileKey = 'financial_profile_v1';

  SharedPreferences? _prefs;
  FinancialProfile _profile = FinancialProfile.empty();
  bool _isLoaded = false;

  FinancialProfile get profile => _profile;
  bool get isLoaded => _isLoaded;
  bool get onboardingCompleted => _profile.onboardingCompleted;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    final raw = _prefs!.getString(profileKey);

    if (raw == null || raw.isEmpty) {
      _profile = FinancialProfile.empty();
    } else {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        _profile = FinancialProfile.fromMap(Map<String, dynamic>.from(decoded));
      } else {
        _profile = FinancialProfile.empty();
      }
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required List<String> incomeTypes,
    required List<String> expenseCategories,
    required String? primaryGoal,
  }) async {
    final now = DateTime.now();
    _profile = _profile.copyWith(
      selectedIncomeTypes: _unique(incomeTypes),
      selectedExpenseCategories: _unique(expenseCategories),
      primaryGoal: primaryGoal,
      onboardingCompleted: true,
      createdAt: _profile.createdAt,
      updatedAt: now,
    );
    await _save();
    notifyListeners();
  }

  Future<void> updateIncomeTypes(List<String> incomeTypes) async {
    _profile = _profile.copyWith(
      selectedIncomeTypes: _unique(incomeTypes),
      updatedAt: DateTime.now(),
    );
    await _save();
    notifyListeners();
  }

  Future<void> updateExpenseCategories(List<String> expenseCategories) async {
    _profile = _profile.copyWith(
      selectedExpenseCategories: _unique(expenseCategories),
      updatedAt: DateTime.now(),
    );
    await _save();
    notifyListeners();
  }

  Future<void> updatePrimaryGoal(String? primaryGoal) async {
    _profile = _profile.copyWith(
      primaryGoal: primaryGoal,
      updatedAt: DateTime.now(),
    );
    await _save();
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    _profile = FinancialProfile.empty().copyWith(
      onboardingCompleted: true,
      updatedAt: DateTime.now(),
    );
    await _save();
    notifyListeners();
  }

  bool isCategoryEnabled(String profileExpenseId) {
    if (_profile.selectedExpenseCategories.isEmpty) return true;
    return _profile.selectedExpenseCategories.contains(profileExpenseId);
  }

  Future<void> _save() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(profileKey, jsonEncode(_profile.toMap()));
  }

  List<String> _unique(List<String> values) {
    return values.where((value) => value.trim().isNotEmpty).toSet().toList();
  }
}

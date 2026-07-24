import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense_category.dart';
import '../services/category_catalog.dart';

class CategoryCatalogProvider extends ChangeNotifier {
  static const _customCategoriesKey = 'customExpenseCategories';
  static const _customSubcategoriesKey = 'customExpenseSubcategories';

  SharedPreferences? _prefs;
  final List<ExpenseCategory> _customCategories = [];
  final Map<String, List<ExpenseSubcategory>> _customSubcategories = {};

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _loadCustomCategories();
    _loadCustomSubcategories();
    notifyListeners();
  }

  List<ExpenseCategory> get categories {
    return [
      ...CategoryCatalog.systemCategories.map(_withCustomSubcategories),
      ..._customCategories.map(_withCustomSubcategories),
    ];
  }

  ExpenseCategory categoryById(String id) {
    return categories.firstWhere(
      (category) => category.id == id,
      orElse: () => CategoryCatalog.categoryForLegacyName(id),
    );
  }

  ExpenseCategory categoryByName(String name) {
    final key = ExpenseCategory.normalizeKey(name);
    return categories.firstWhere(
      (category) => ExpenseCategory.normalizeKey(category.name) == key,
      orElse: () => CategoryCatalog.categoryForLegacyName(name),
    );
  }

  List<ExpenseSubcategory> subcategoriesFor(String categoryId) {
    return categoryById(categoryId).subcategories;
  }

  bool categoryExists(String name) {
    final key = ExpenseCategory.normalizeKey(name);
    return categories
        .any((category) => ExpenseCategory.normalizeKey(category.name) == key);
  }

  bool subcategoryExists(String categoryId, String name) {
    final key = ExpenseCategory.normalizeKey(name);
    return subcategoriesFor(categoryId).any(
        (subcategory) => ExpenseCategory.normalizeKey(subcategory.name) == key);
  }

  Future<ExpenseCategory?> addCustomCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || categoryExists(trimmed)) return null;

    final category = ExpenseCategory.custom(trimmed);
    _customCategories.add(category);
    await _saveCustomCategories();
    notifyListeners();
    return category;
  }

  Future<ExpenseSubcategory?> addCustomSubcategory(
      String categoryId, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || subcategoryExists(categoryId, trimmed)) return null;

    final subcategory = ExpenseSubcategory.custom(trimmed);
    final list = _customSubcategories.putIfAbsent(categoryId, () => []);
    list.add(subcategory);
    await _saveCustomSubcategories();
    notifyListeners();
    return subcategory;
  }

  ExpenseCategory _withCustomSubcategories(ExpenseCategory category) {
    final custom =
        _customSubcategories[category.id] ?? const <ExpenseSubcategory>[];
    if (custom.isEmpty) return category;

    return category.copyWith(
      subcategories: [
        ...category.subcategories,
        ...custom,
      ],
    );
  }

  void _loadCustomCategories() {
    _customCategories.clear();
    final raw = _prefs?.getString(_customCategoriesKey);
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw);
    if (decoded is! List) return;

    _customCategories.addAll(
      decoded.whereType<Map>().map(
          (map) => ExpenseCategory.fromMap(Map<String, dynamic>.from(map))),
    );
  }

  void _loadCustomSubcategories() {
    _customSubcategories.clear();
    final raw = _prefs?.getString(_customSubcategoriesKey);
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw);
    if (decoded is! Map) return;

    for (final entry in decoded.entries) {
      final value = entry.value;
      if (value is! List) continue;
      _customSubcategories[entry.key.toString()] = value
          .whereType<Map>()
          .map((map) =>
              ExpenseSubcategory.fromMap(Map<String, dynamic>.from(map)))
          .toList();
    }
  }

  Future<void> _saveCustomCategories() async {
    await _prefs?.setString(
      _customCategoriesKey,
      jsonEncode(
          _customCategories.map((category) => category.toMap()).toList()),
    );
  }

  Future<void> _saveCustomSubcategories() async {
    final payload = _customSubcategories.map(
      (key, value) => MapEntry(
          key, value.map((subcategory) => subcategory.toMap()).toList()),
    );
    await _prefs?.setString(_customSubcategoriesKey, jsonEncode(payload));
  }
}

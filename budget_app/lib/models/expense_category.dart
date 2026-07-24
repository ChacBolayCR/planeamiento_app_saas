import 'package:flutter/material.dart';

class ExpenseSubcategory {
  final String id;
  final String name;
  final bool isSystem;
  final bool isCustom;

  const ExpenseSubcategory({
    required this.id,
    required this.name,
    this.isSystem = true,
    this.isCustom = false,
  });

  factory ExpenseSubcategory.custom(String name) {
    return ExpenseSubcategory(
      id: 'custom_${ExpenseCategory.normalizeKey(name)}',
      name: name.trim(),
      isSystem: false,
      isCustom: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isSystem': isSystem,
      'isCustom': isCustom,
    };
  }

  factory ExpenseSubcategory.fromMap(Map<String, dynamic> map) {
    return ExpenseSubcategory(
      id: (map['id'] as String?) ??
          'custom_${ExpenseCategory.normalizeKey(map['name'] as String? ?? '')}',
      name: (map['name'] as String?) ?? 'Otro',
      isSystem: map['isSystem'] as bool? ?? false,
      isCustom: map['isCustom'] as bool? ?? true,
    );
  }
}

class ExpenseCategory {
  final String id;
  final String name;
  final IconData icon;
  final List<ExpenseSubcategory> subcategories;
  final bool isSystem;
  final bool isCustom;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.subcategories,
    this.isSystem = true,
    this.isCustom = false,
  });

  factory ExpenseCategory.custom(String name) {
    return ExpenseCategory(
      id: 'custom_${normalizeKey(name)}',
      name: name.trim(),
      icon: Icons.label_outline,
      subcategories: const [
        ExpenseSubcategory(id: 'other', name: 'Otro'),
      ],
      isSystem: false,
      isCustom: true,
    );
  }

  ExpenseCategory copyWith({
    String? id,
    String? name,
    IconData? icon,
    List<ExpenseSubcategory>? subcategories,
    bool? isSystem,
    bool? isCustom,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      subcategories: subcategories ?? this.subcategories,
      isSystem: isSystem ?? this.isSystem,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subcategories': subcategories.map((s) => s.toMap()).toList(),
      'isSystem': isSystem,
      'isCustom': isCustom,
    };
  }

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    final name = (map['name'] as String?) ?? 'Otros';
    final rawSubs = map['subcategories'];

    return ExpenseCategory(
      id: (map['id'] as String?) ?? 'custom_${normalizeKey(name)}',
      name: name,
      icon: Icons.label_outline,
      subcategories: rawSubs is List
          ? rawSubs
              .whereType<Map>()
              .map((m) =>
                  ExpenseSubcategory.fromMap(Map<String, dynamic>.from(m)))
              .toList()
          : const [ExpenseSubcategory(id: 'other', name: 'Otro')],
      isSystem: map['isSystem'] as bool? ?? false,
      isCustom: map['isCustom'] as bool? ?? true,
    );
  }

  static String normalizeKey(String value) {
    final lower = value.trim().toLowerCase();
    const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const to = 'aaaaaeeeeiiiiooooouuuunc';
    final buffer = StringBuffer();

    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      final index = from.indexOf(char);
      final normalized = index >= 0 ? to[index] : char;
      if (RegExp(r'[a-z0-9]').hasMatch(normalized)) {
        buffer.write(normalized);
      }
    }

    return buffer.isEmpty ? 'custom' : buffer.toString();
  }
}

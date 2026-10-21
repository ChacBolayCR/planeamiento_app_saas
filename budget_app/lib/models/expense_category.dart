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
    final buffer = StringBuffer();

    for (final rune in value.trim().toLowerCase().runes) {
      final normalized = _normalizeRune(rune);
      if (RegExp(r'[a-z0-9]').hasMatch(normalized)) {
        buffer.write(normalized);
      }
    }

    return buffer.isEmpty ? 'custom' : buffer.toString();
  }

  static String _normalizeRune(int rune) {
    return switch (rune) {
      0x00E1 || 0x00E0 || 0x00E4 || 0x00E2 || 0x00E3 => 'a',
      0x00E9 || 0x00E8 || 0x00EB || 0x00EA => 'e',
      0x00ED || 0x00EC || 0x00EF || 0x00EE => 'i',
      0x00F3 || 0x00F2 || 0x00F6 || 0x00F4 || 0x00F5 => 'o',
      0x00FA || 0x00F9 || 0x00FC || 0x00FB => 'u',
      0x00F1 => 'n',
      0x00E7 => 'c',
      _ => String.fromCharCode(rune),
    };
  }
}

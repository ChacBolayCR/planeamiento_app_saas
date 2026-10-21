import '../services/category_catalog.dart';

class Expense {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String categoryName;
  final String? subcategoryId;
  final String? subcategoryName;
  final String? commitmentId;
  final bool isRecurring;

  Expense({
    String? id,
    required this.title,
    required String category,
    required this.amount,
    required this.date,
    String? categoryId,
    String? categoryName,
    this.subcategoryId,
    this.subcategoryName,
    this.commitmentId,
    this.isRecurring = false,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        category = categoryName ?? category,
        categoryName = categoryName ?? category,
        categoryId =
            categoryId ?? CategoryCatalog.categoryForLegacyName(category).id;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'categoryName': categoryName,
      'subcategoryId': subcategoryId,
      'subcategoryName': subcategoryName,
      'commitmentId': commitmentId,
      'isRecurring': isRecurring,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    final legacyCategory = map['category'] as String?;
    final categoryName =
        map['categoryName'] as String? ?? legacyCategory ?? 'General';
    final categoryId = map['categoryId'] as String? ??
        CategoryCatalog.categoryForLegacyName(categoryName).id;

    return Expense(
      id: map['id'] as String?,
      title: map['title'] as String? ?? '',
      category: legacyCategory ?? categoryName,
      categoryId: categoryId,
      categoryName: categoryName,
      subcategoryId: map['subcategoryId'] as String?,
      subcategoryName: map['subcategoryName'] as String?,
      commitmentId: map['commitmentId'] as String?,
      isRecurring: map['isRecurring'] as bool? ?? false,
      amount: _readDouble(map['amount']),
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static double _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

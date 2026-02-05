import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;

  Expense({
    String? id,
    required this.title,
    required this.category,
    required this.amount,
    DateTime? date,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();
}

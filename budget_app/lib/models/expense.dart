class Expense {
  final String title;
  final String category;
  final double amount;
  final DateTime date;

  Expense({
    required this.title,
    required this.category,
    required this.amount,
    DateTime? date,
  }) : date = date ?? DateTime.now();
}

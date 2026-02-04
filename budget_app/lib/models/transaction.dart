class TransactionModel {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final bool isIncome;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.isIncome,
  });
}

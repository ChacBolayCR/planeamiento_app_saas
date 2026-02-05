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
    required this.date,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'amount': amount,
        'date': date.toIso8601String(),
      };
}

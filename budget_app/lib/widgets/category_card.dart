import 'package:flutter/material.dart';
import '../models/expense.dart';

class CategoryCard extends StatelessWidget {
  final List<Expense> expenses;
  final String currencySymbol;

  const CategoryCard({
    super.key,
    required this.expenses,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Text("Aún no hay gastos registrados");
    }

    final Map<String, double> totals = {};

    for (final e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gastos por categoría",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...totals.entries.map(
          (entry) => ListTile(
            title: Text(entry.key),
            trailing: Text(
              "$currencySymbol${entry.value.toStringAsFixed(2)}",
            ),
          ),
        ),
      ],
    );
  }
}

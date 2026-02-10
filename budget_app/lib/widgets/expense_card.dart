import 'package:flutter/material.dart';

class ExpenseCard extends StatelessWidget {
  final double totalExpenses;
  final String currencySymbol;

  const ExpenseCard({
    super.key,
    required this.totalExpenses,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gastos del mes',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              '$currencySymbol${totalExpenses.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final double budget;
  final double spent;
  final String currencySymbol;

  const BalanceCard({
    super.key,
    required this.budget,
    required this.spent,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = budget - spent;
    final double percentUsed = budget <= 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);
    final int remainingPct = ((1.0 - percentUsed) * 100).round();
    final int usedPct = (percentUsed * 100).round();


    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Presupuesto restante',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              '$currencySymbol${remaining.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: remaining >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentUsed.toDouble(),
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Usado: $usedPct%'),
                Text('Restante: $remainingPct%'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

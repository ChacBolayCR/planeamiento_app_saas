import 'package:flutter/material.dart';

class MonthlyOverviewCard extends StatelessWidget {
  final double budget;
  final double spent;
  final String currencySymbol;

  const MonthlyOverviewCard({
    super.key,
    required this.budget,
    required this.spent,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = budget - spent;

    final double percentUsed =
        budget <= 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);

    final int usedPct = (percentUsed * 100).round();
    final int remainingPct = ((1.0 - percentUsed) * 100).round();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del mes',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Gastado',
                    value: '$currencySymbol${spent.toStringAsFixed(2)}',
                    valueStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(
                    label: 'Restante',
                    value: '$currencySymbol${remaining.toStringAsFixed(2)}',
                    valueStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: remaining >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: percentUsed,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Usado: $usedPct%'),
                Text('Restante: $remainingPct%'),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              'Presupuesto: $currencySymbol${budget.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle valueStyle;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 6),
        Text(value, style: valueStyle),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../models/expense.dart';

class CategoryBarChartCard extends StatelessWidget {
  final List<Expense> expenses;
  final String currencySymbol;
  final int maxBars;

  const CategoryBarChartCard({
    super.key,
    required this.expenses,
    required this.currencySymbol,
    this.maxBars = 6,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    // Totales por categoría
    final Map<String, double> totals = {};
    for (final e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }

    if (totals.isEmpty) return const SizedBox.shrink();

    final items = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top = items.take(maxBars).toList();
    final maxVal = top.first.value;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gastos por categoría',
              style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),

            ...top.map((e) {
              final ratio = (e.value / maxVal).clamp(0.0, 1.0);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BarRow(
                  label: e.key,
                  value: e.value,
                  ratio: ratio,
                  currencySymbol: currencySymbol,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double value;
  final double ratio;
  final String currencySymbol;

  const _BarRow({
    required this.label,
    required this.value,
    required this.ratio,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$currencySymbol ${value.toStringAsFixed(0)}',
              style: t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth * ratio;
            return Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  height: 10,
                  width: w,
                  decoration: BoxDecoration(
                    color: t.colorScheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
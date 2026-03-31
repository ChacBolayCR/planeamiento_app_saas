import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/budget_provider.dart';

class MonthlyTrendChartCard extends StatelessWidget {
  final int months; // últimos N meses
  const MonthlyTrendChartCard({super.key, this.months = 6});

  List<DateTime> _lastMonths(DateTime now, int count) {
    final firstOfNow = DateTime(now.year, now.month, 1);
    return List.generate(count, (i) {
      final m = DateTime(firstOfNow.year, firstOfNow.month - (count - 1 - i), 1);
      return m;
    });
  }

  String _label(DateTime d) {
    const names = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    return '${names[d.month - 1]} ${d.year.toString().substring(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final budget = context.watch<BudgetProvider>();

    final monthsList = _lastMonths(DateTime.now(), months);

    return FutureBuilder<List<double>>(
      future: () async {
        final values = <double>[];
        for (final m in monthsList) {
          values.add(budget.totalSpentForMonth(m));
        }
        return values;
      }(),
      builder: (context, snap) {
        final values = snap.data;

        return Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(
  builder: (_) {
    double? change;
    if (values != null && values.length >= 2) {
      final last = values.last;
      final prev = values[values.length - 2];
      if (prev > 0) {
        change = ((last - prev) / prev) * 100;
      }
    }

    final isUp = (change ?? 0) > 0;

    return Row(
      children: [
        Text(
          'Tendencia $months meses',
          style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 8),

        if (change != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isUp
                  ? Colors.red.withOpacity(0.15)
                  : Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Icon(
                  isUp ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: isUp ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  '${change.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isUp ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  },
),
                const SizedBox(height: 4),
                Text(
                  'Gasto total por mes',
                  style: t.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 12),

                if (snap.connectionState == ConnectionState.waiting || values == null) ...[
                  const SizedBox(height: 8),
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 8),
                ] else ...[
                  _Bars(
                    labels: monthsList.map(_label).toList(),
                    values: values,
                    currencySymbol: budget.currencySymbol,
                    budget: budget.monthlyBudget,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Bars extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final String currencySymbol;
  final double budget;

  const _Bars({
    required this.labels,
    required this.values,
    required this.currencySymbol,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final maxVal = values.isEmpty ? 1.0 : (values.reduce((a, b) => a > b ? a : b));
    final safeMax = maxVal <= 0 ? 1.0 : maxVal;

    return Column(
      children: List.generate(values.length, (i) {
        final v = values[i];
        final ratio = (v / safeMax).clamp(0.0, 1.0);
        final overBudget = budget > 0 && v > budget;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      labels[i],
                      style: t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (_, c) {
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
                                color: overBudget ? Colors.redAccent : t.colorScheme.primary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$currencySymbol ${v.toStringAsFixed(0)}',
                    style: t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              if (budget > 0) ...[
                const SizedBox(height: 4),
                Text(
                  overBudget ? 'Sobre presupuesto' : 'OK vs presupuesto',
                  style: t.textTheme.bodySmall?.copyWith(
                    color: overBudget ? Colors.redAccent : Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}
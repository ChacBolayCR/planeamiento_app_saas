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
    final percentUsed = budget <= 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            final stackStats = constraints.maxWidth < 300 || textScale > 1.15;
            final spentStat = _MiniStat(
              label: 'Gastado',
              value: '$currencySymbol${spent.toStringAsFixed(0)}',
              valueColor: colorScheme.onSurface,
            );
            final remainingStat = _MiniStat(
              label: 'Restante',
              value: '$currencySymbol${remaining.toStringAsFixed(0)}',
              valueColor: remaining >= 0 ? Colors.green : Colors.red,
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen del mes',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (stackStats) ...[
                  spentStat,
                  const SizedBox(height: 10),
                  remainingStat,
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: spentStat),
                      const SizedBox(width: 12),
                      Expanded(child: remainingStat),
                    ],
                  ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: percentUsed,
                    minHeight: 6,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          softWrap: true,
          style: theme.textTheme.titleMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

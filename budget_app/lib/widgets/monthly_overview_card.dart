import 'package:flutter/material.dart';

import '../design_system/components/kiki_card.dart';
import '../design_system/kiki_colors.dart';
import '../design_system/kiki_spacing.dart';

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

    return KikiCard(
      semanticLabel: 'Resumen del mes',
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
            valueColor: remaining >= 0 ? KikiColors.success : KikiColors.error,
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen del mes',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: KikiSpacing.md),
              if (stackStats) ...[
                spentStat,
                const SizedBox(height: KikiSpacing.sm),
                remainingStat,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: spentStat),
                    const SizedBox(width: KikiSpacing.md),
                    Expanded(child: remainingStat),
                  ],
                ),
              const SizedBox(height: KikiSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: percentUsed,
                  minHeight: 7,
                ),
              ),
            ],
          );
        },
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
        const SizedBox(height: KikiSpacing.xs),
        Text(
          value,
          softWrap: true,
          style: theme.textTheme.titleMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../design_system/components/kiki_card.dart';
import '../design_system/kiki_colors.dart';
import '../design_system/kiki_radius.dart';
import '../design_system/kiki_spacing.dart';

class KikiScoreCard extends StatelessWidget {
  final int score;

  const KikiScoreCard({
    super.key,
    required this.score,
  });

  Color _scoreColor() {
    if (score >= 90) return KikiColors.success;
    if (score >= 75) return const Color(0xFF6FAF52);
    if (score >= 60) return KikiColors.warning;
    return KikiColors.error;
  }

  String _scoreLabel() {
    if (score >= 90) return 'Excelente';
    if (score >= 75) return 'Muy bien';
    if (score >= 60) return 'Aceptable';
    return 'A mejorar';
  }

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return KikiCard(
      semanticLabel: 'Resumen financiero $score de 100',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(KikiRadius.medium),
            ),
            child: Icon(
              Icons.insights_rounded,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: KikiSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Resumen', style: theme.textTheme.titleSmall),
                const SizedBox(height: KikiSpacing.sm),
                RichText(
                  textScaler: MediaQuery.textScalerOf(context),
                  text: TextSpan(
                    text: '$score',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                    children: [
                      TextSpan(
                        text: '/100',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KikiSpacing.xs),
                Text(
                  _scoreLabel(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

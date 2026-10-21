import 'package:flutter/material.dart';

import '../kiki_colors.dart';
import '../kiki_spacing.dart';
import '../kiki_typography.dart';
import 'kiki_card.dart';

class KikiStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? description;
  final IconData icon;
  final Color? color;

  const KikiStatCard({
    super.key,
    required this.label,
    required this.value,
    this.description,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? KikiColors.primary;
    return KikiCard(
      semanticLabel: '$label $value',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent, size: 26),
          ),
          const SizedBox(width: KikiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: KikiSpacing.xs),
                Text(value,
                    style: KikiTypography.amountMedium.copyWith(color: accent)),
                if (description != null) ...[
                  const SizedBox(height: KikiSpacing.xs),
                  Text(description!,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../kiki_colors.dart';
import '../kiki_radius.dart';
import '../kiki_spacing.dart';

class KikiChoiceCard extends StatelessWidget {
  final String title;
  final String? description;
  final IconData? icon;
  final Widget? leading;
  final bool selected;
  final VoidCallback onTap;
  final bool fullWidth;

  const KikiChoiceCard({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.leading,
    required this.selected,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? KikiColors.primary : KikiColors.textSecondary;
    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.all(KikiSpacing.md),
      decoration: BoxDecoration(
        color: selected ? KikiColors.surfaceSoft : KikiColors.surface,
        borderRadius: BorderRadius.circular(KikiRadius.medium),
        border: Border.all(
            color: selected ? KikiColors.primary : KikiColors.border),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading ??
              Icon(icon ?? Icons.check_circle_outline, color: color, size: 20),
          const SizedBox(width: KikiSpacing.sm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: theme.textTheme.labelLarge),
                if (description != null) ...[
                  const SizedBox(height: 3),
                  Text(description!, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (selected) ...[
            const SizedBox(width: KikiSpacing.sm),
            const Icon(Icons.check_circle, color: KikiColors.primary, size: 18),
          ],
        ],
      ),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(KikiRadius.medium),
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}

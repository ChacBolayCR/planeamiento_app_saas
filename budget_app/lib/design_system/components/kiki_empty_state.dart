import 'package:flutter/material.dart';

import '../kiki_spacing.dart';
import 'kiki_button.dart';
import 'kiki_card.dart';

class KikiEmptyState extends StatelessWidget {
  final IconData? icon;
  final String? assetPath;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? action;

  const KikiEmptyState({
    super.key,
    this.icon,
    this.assetPath,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return KikiCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (assetPath != null)
            Image.asset(
              assetPath!,
              height: 132,
              fit: BoxFit.contain,
              alignment: Alignment.center,
            )
          else if (icon != null)
            Icon(icon, size: 34, color: theme.colorScheme.primary),
          const SizedBox(height: KikiSpacing.sm),
          Text(title,
              style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: KikiSpacing.xs),
          Text(message,
              style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: KikiSpacing.md),
            action!,
          ] else if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: KikiSpacing.md),
            KikiButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}

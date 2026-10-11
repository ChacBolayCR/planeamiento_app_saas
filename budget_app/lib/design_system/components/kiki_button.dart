import 'package:flutter/material.dart';

enum KikiButtonVariant { primary, secondary, outline, text, destructive }

class KikiButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final KikiButtonVariant variant;
  final bool loading;
  final IconData? icon;

  const KikiButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = KikiButtonVariant.primary,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(label)),
            ],
          );
    final enabled = loading ? null : onPressed;

    return Semantics(
      button: true,
      enabled: enabled != null,
      label: label,
      child: switch (variant) {
        KikiButtonVariant.primary =>
          ElevatedButton(onPressed: enabled, child: child),
        KikiButtonVariant.secondary =>
          FilledButton.tonal(onPressed: enabled, child: child),
        KikiButtonVariant.outline =>
          OutlinedButton(onPressed: enabled, child: child),
        KikiButtonVariant.text => TextButton(onPressed: enabled, child: child),
        KikiButtonVariant.destructive => ElevatedButton.icon(
            onPressed: enabled,
            icon: loading
                ? const SizedBox.shrink()
                : Icon(icon ?? Icons.warning_rounded),
            label: loading ? child : Text(label),
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
          ),
      },
    );
  }
}

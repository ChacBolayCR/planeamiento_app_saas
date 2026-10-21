import 'package:flutter/material.dart';

import '../kiki_colors.dart';
import '../kiki_radius.dart';
import '../kiki_shadows.dart';
import '../kiki_spacing.dart';

enum KikiCardVariant { standard, soft, highlighted, success, warning, error }

class KikiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final KikiCardVariant variant;

  const KikiCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(KikiSpacing.lg),
    this.margin,
    this.onTap,
    this.semanticLabel,
    this.variant = KikiCardVariant.standard,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForVariant();
    final content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(KikiRadius.large),
        border: Border.all(color: colors.$2),
        boxShadow: KikiShadows.subtle,
      ),
      child: Padding(padding: padding, child: child),
    );

    final semantic = Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: content,
    );

    if (onTap == null) return semantic;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(KikiRadius.large),
        onTap: onTap,
        child: semantic,
      ),
    );
  }

  (Color, Color) _colorsForVariant() {
    return switch (variant) {
      KikiCardVariant.soft => (KikiColors.surfaceSoft, KikiColors.border),
      KikiCardVariant.highlighted => (
          KikiColors.primary.withValues(alpha: 0.08),
          KikiColors.secondaryLavender
        ),
      KikiCardVariant.success => (KikiColors.successSoft, KikiColors.success),
      KikiCardVariant.warning => (KikiColors.warningSoft, KikiColors.warning),
      KikiCardVariant.error => (KikiColors.errorSoft, KikiColors.error),
      KikiCardVariant.standard => (KikiColors.surface, KikiColors.border),
    };
  }
}

import 'package:flutter/material.dart';

import '../kiki_colors.dart';
import '../kiki_radius.dart';
import '../kiki_spacing.dart';

enum KikiInfoBannerVariant { neutral, success, warning, error }

class KikiInfoBanner extends StatelessWidget {
  final String message;
  final KikiInfoBannerVariant variant;
  final IconData? icon;

  const KikiInfoBanner({
    super.key,
    required this.message,
    this.variant = KikiInfoBannerVariant.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForVariant();
    final usedIcon = icon ??
        switch (variant) {
          KikiInfoBannerVariant.success => Icons.check_circle_outline,
          KikiInfoBannerVariant.warning => Icons.info_outline,
          KikiInfoBannerVariant.error => Icons.error_outline,
          KikiInfoBannerVariant.neutral => Icons.auto_awesome_outlined,
        };

    return Semantics(
      liveRegion: variant != KikiInfoBannerVariant.neutral,
      child: Container(
        padding: const EdgeInsets.all(KikiSpacing.md),
        decoration: BoxDecoration(
          color: colors.$1,
          borderRadius: BorderRadius.circular(KikiRadius.medium),
          border: Border.all(color: colors.$2.withValues(alpha: 0.38)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(usedIcon, color: colors.$2, size: 20),
            const SizedBox(width: KikiSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  (Color, Color) _colorsForVariant() {
    return switch (variant) {
      KikiInfoBannerVariant.success => (
          KikiColors.successSoft,
          KikiColors.success
        ),
      KikiInfoBannerVariant.warning => (
          KikiColors.warningSoft,
          KikiColors.warning
        ),
      KikiInfoBannerVariant.error => (KikiColors.errorSoft, KikiColors.error),
      KikiInfoBannerVariant.neutral => (KikiColors.infoSoft, KikiColors.info),
    };
  }
}

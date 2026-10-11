import 'package:flutter/material.dart';

import 'kiki_colors.dart';

class KikiTypography {
  const KikiTypography._();

  static const fontFamily = null;

  static TextTheme textTheme() {
    return const TextTheme(
      displaySmall: TextStyle(
        fontSize: 30,
        height: 1.12,
        fontWeight: FontWeight.w800,
        color: KikiColors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        height: 1.18,
        fontWeight: FontWeight.w800,
        color: KikiColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        height: 1.24,
        fontWeight: FontWeight.w800,
        color: KikiColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.30,
        fontWeight: FontWeight.w700,
        color: KikiColors.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        height: 1.30,
        fontWeight: FontWeight.w700,
        color: KikiColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.45,
        fontWeight: FontWeight.w500,
        color: KikiColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.42,
        fontWeight: FontWeight.w500,
        color: KikiColors.textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.35,
        fontWeight: FontWeight.w500,
        color: KikiColors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        height: 1.20,
        fontWeight: FontWeight.w800,
        color: KikiColors.textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        height: 1.20,
        fontWeight: FontWeight.w700,
        color: KikiColors.textSecondary,
      ),
    );
  }

  static const amountLarge = TextStyle(
    fontSize: 28,
    height: 1.05,
    fontWeight: FontWeight.w800,
    color: KikiColors.textPrimary,
  );

  static const amountMedium = TextStyle(
    fontSize: 18,
    height: 1.12,
    fontWeight: FontWeight.w800,
    color: KikiColors.textPrimary,
  );
}

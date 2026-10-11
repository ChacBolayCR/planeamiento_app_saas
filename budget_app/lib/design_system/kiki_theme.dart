import 'package:flutter/material.dart';

import 'kiki_colors.dart';
import 'kiki_radius.dart';
import 'kiki_spacing.dart';
import 'kiki_typography.dart';

class KikiTheme {
  const KikiTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: KikiColors.primary,
      brightness: Brightness.light,
      primary: KikiColors.primary,
      onPrimary: KikiColors.surface,
      primaryContainer: KikiColors.surfaceSoft,
      onPrimaryContainer: KikiColors.primaryDeep,
      secondary: KikiColors.secondaryLavender,
      surface: KikiColors.surface,
      onSurface: KikiColors.textPrimary,
      error: KikiColors.error,
      onError: KikiColors.surface,
      outline: KikiColors.border,
    );

    final textTheme = KikiTypography.textTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: KikiColors.background,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: KikiColors.background,
        foregroundColor: KikiColors.textPrimary,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: KikiColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: KikiColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KikiRadius.large),
          side: const BorderSide(color: KikiColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KikiColors.primary,
          foregroundColor: KikiColors.surface,
          disabledBackgroundColor: KikiColors.surfaceSoft,
          disabledForegroundColor: KikiColors.textDisabled,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KikiRadius.medium),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: KikiColors.primary,
          foregroundColor: KikiColors.surface,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KikiRadius.medium),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KikiColors.primary,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: KikiColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KikiRadius.medium),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KikiColors.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: KikiColors.primaryBright,
        foregroundColor: KikiColors.surface,
        elevation: 2,
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KikiColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: KikiSpacing.lg,
          vertical: KikiSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KikiRadius.medium),
          borderSide: const BorderSide(color: KikiColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KikiRadius.medium),
          borderSide: const BorderSide(color: KikiColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KikiRadius.medium),
          borderSide: const BorderSide(color: KikiColors.primary, width: 1.4),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: KikiColors.surface,
        selectedItemColor: KikiColors.primary,
        unselectedItemColor: KikiColors.textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: KikiColors.surface,
        indicatorColor: KikiColors.surfaceSoft,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: KikiColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KikiRadius.large),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: KikiColors.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: KikiColors.surface,
        modalBarrierColor: Color(0x66000000),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: KikiColors.primaryDeep,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: KikiColors.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KikiRadius.medium),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: KikiColors.surfaceSoft,
        selectedColor: KikiColors.secondaryLavender.withValues(alpha: 0.38),
        disabledColor: KikiColors.surfaceSoft,
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KikiRadius.pill),
          side: const BorderSide(color: KikiColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: KikiColors.border,
        thickness: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: KikiColors.primaryBright,
        linearTrackColor: KikiColors.surfaceSoft,
      ),
    );
  }
}

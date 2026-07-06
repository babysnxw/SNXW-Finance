import 'package:flutter/material.dart';

import 'colors.dart';
import 'elevation.dart';
import 'radius.dart';
import 'spacing.dart';
import 'typography.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme colorScheme = isDark
        ? const ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            tertiary: AppColors.success,
            error: AppColors.error,
            surface: AppColors.surface,
            onSurface: AppColors.neutral900,
            onSurfaceVariant: AppColors.neutral600,
          )
        : const ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            tertiary: AppColors.success,
            error: AppColors.error,
            surface: AppColors.surface,
            onSurface: AppColors.neutral900,
            onSurfaceVariant: AppColors.neutral600,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppTypography.textTheme(colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: colorScheme.onSurface,
        elevation: AppElevation.none,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: AppElevation.none,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: AppColors.neutral200),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          textStyle: AppTypography.label,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }
}
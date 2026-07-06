import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const TextStyle display = TextStyle(
    fontSize: 34,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 24,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  static TextTheme textTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: display.copyWith(color: colorScheme.onSurface),
      headlineLarge: headline.copyWith(color: colorScheme.onSurface),
      titleLarge: title.copyWith(color: colorScheme.onSurface),
      bodyLarge: body.copyWith(color: colorScheme.onSurface),
      labelLarge: label.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }
}
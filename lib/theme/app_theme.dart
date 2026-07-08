import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.lightSurface,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
  );

  static ThemeData get dark => _build(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
  );

  static ThemeData _build({
    required ColorScheme colorScheme,
    required Color scaffoldBackgroundColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textTheme: Typography.material2021().black.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scaffoldBackgroundColor,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

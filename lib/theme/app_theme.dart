import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light(Locale locale) => _build(
    colorScheme: _colorScheme(Brightness.light),
    scaffoldBackgroundColor: AppColors.lightBackground,
    locale: locale,
  );

  static ThemeData dark(Locale locale) => _build(
    colorScheme: _colorScheme(Brightness.dark),
    scaffoldBackgroundColor: AppColors.darkBackground,
    locale: locale,
  );

  static ColorScheme _colorScheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ColorScheme.fromSeed(
      seedColor: isDark ? AppColors.primaryDark : AppColors.primary,
      brightness: brightness,
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      error: AppColors.error,
    );

    return base.copyWith(
      primary: isDark ? AppColors.primaryDark : AppColors.primary,
      onPrimary: AppColors.secondary,
      primaryContainer: isDark
          ? const Color(0xFF4A3E17)
          : const Color(0xFFFFF4CC),
      onPrimaryContainer: isDark
          ? const Color(0xFFFFE79A)
          : AppColors.secondary,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: isDark
          ? const Color(0xFF1A2D5E)
          : const Color(0xFFE8EDFA),
      onSecondaryContainer: isDark
          ? const Color(0xFFDCE5FF)
          : AppColors.secondary,
    );
  }

  static ThemeData _build({
    required ColorScheme colorScheme,
    required Color scaffoldBackgroundColor,
    required Locale locale,
  }) {
    final textTheme = _textTheme(colorScheme, locale);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textTheme: textTheme,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme colorScheme, Locale locale) {
    final baseTheme = Typography.material2021().black.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    if (locale.languageCode != 'km') {
      return baseTheme;
    }

    final bodyTheme = GoogleFonts.getTextTheme('Battambang', baseTheme);

    TextStyle? moul(TextStyle? style) {
      if (style == null) return null;
      return GoogleFonts.getFont('Moul', textStyle: style);
    }

    return bodyTheme.copyWith(
      displayLarge: moul(bodyTheme.displayLarge),
      displayMedium: moul(bodyTheme.displayMedium),
      displaySmall: moul(bodyTheme.displaySmall),
      headlineLarge: moul(bodyTheme.headlineLarge),
      headlineMedium: moul(bodyTheme.headlineMedium),
      headlineSmall: moul(bodyTheme.headlineSmall),
      titleLarge: moul(bodyTheme.titleLarge),
      titleMedium: moul(bodyTheme.titleMedium),
      titleSmall: moul(bodyTheme.titleSmall),
    );
  }
}

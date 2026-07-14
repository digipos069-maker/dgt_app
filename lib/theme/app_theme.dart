import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light(Locale locale) => _build(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.lightSurface,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    locale: locale,
  );

  static ThemeData dark(Locale locale) => _build(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    locale: locale,
  );

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

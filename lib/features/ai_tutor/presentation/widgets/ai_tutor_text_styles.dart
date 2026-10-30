import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Makes sure Khmer always renders in the tutor, even when the app language
/// is English (whose theme font has no Khmer glyphs).
TextStyle? withKhmerFallback(TextStyle? style) {
  final khmerFamily = GoogleFonts.battambang().fontFamily;
  if (style == null || khmerFamily == null) return style;
  return style.copyWith(
    fontFamilyFallback: [
      ...?style.fontFamilyFallback,
      khmerFamily,
    ],
  );
}

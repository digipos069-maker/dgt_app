import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

/// Representation of high school tracks in Cambodia's education curriculum.
///
/// Corresponds to API constant:
/// ```typescript
/// export const LESSON_TRACKS: Record<number, string> = {
///   1: "ថ្នាក់វិទ្យាសាស្រ្ដ",
///   2: "ថ្នាក់សង្គម",
/// };
/// ```
abstract final class LessonTrackConstants {
  static const int science = 1;
  static const int social = 2;

  static const Map<int, String> tracks = {
    science: 'ថ្នាក់វិទ្យាសាស្រ្ដ',
    social: 'ថ្នាក់សង្គម',
  };

  static String? getTrackName(int? trackType) {
    if (trackType == null) return null;
    return tracks[trackType];
  }
}

enum LessonTrack {
  science(LessonTrackConstants.science, 'ថ្នាក់វិទ្យាសាស្រ្ដ', 'Science Track'),
  social(LessonTrackConstants.social, 'ថ្នាក់សង្គម', 'Social Science Track');

  const LessonTrack(this.id, this.labelKm, this.labelEn);

  final int id;
  final String labelKm;
  final String labelEn;

  static LessonTrack? fromId(int? id) {
    return switch (id) {
      LessonTrackConstants.science => LessonTrack.science,
      LessonTrackConstants.social => LessonTrack.social,
      _ => null,
    };
  }

  IconData get icon {
    return switch (this) {
      LessonTrack.science => Icons.biotech_outlined,
      LessonTrack.social => Icons.public_outlined,
    };
  }

  /// Color palette for light and dark modes
  Color backgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (this) {
      LessonTrack.science => isDark
          ? const Color(0xFF0C2340)
          : const Color(0xFFEFF6FF),
      LessonTrack.social => isDark
          ? const Color(0xFF3B2A10)
          : const Color(0xFFFFFBEB),
    };
  }

  Color borderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (this) {
      LessonTrack.science => isDark
          ? const Color(0xFF1D4ED8).withValues(alpha: 0.6)
          : const Color(0xFFBFDBFE),
      LessonTrack.social => isDark
          ? const Color(0xFFB45309).withValues(alpha: 0.6)
          : const Color(0xFFFDE68A),
    };
  }

  Color foregroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (this) {
      LessonTrack.science => isDark
          ? const Color(0xFF93C5FD)
          : AppColors.primary,
      LessonTrack.social => isDark
          ? const Color(0xFFFCD34D)
          : const Color(0xFFB45309),
    };
  }
}

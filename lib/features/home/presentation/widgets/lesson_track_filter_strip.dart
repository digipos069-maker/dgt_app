import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/models/lesson_track.dart';

/// An interactive filter strip that lets users filter lessons by track
/// (All, Science Track, Social Science Track).
class LessonTrackFilterStrip extends StatelessWidget {
  const LessonTrackFilterStrip({
    required this.selectedTrack,
    required this.onTrackSelected,
    required this.availableTracks,
    super.key,
  });

  /// Currently selected track (`null` represents 'All').
  final int? selectedTrack;

  /// Callback when a track filter is tapped.
  final ValueChanged<int?> onTrackSelected;

  /// Tracks that actually exist in the current lesson list.
  final Set<int> availableTracks;

  @override
  Widget build(BuildContext context) {
    if (availableTracks.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChipItem(
            label: 'ទាំងអស់',
            icon: Icons.apps_outlined,
            isSelected: selectedTrack == null,
            onTap: () => onTrackSelected(null),
            isDark: isDark,
          ),
          if (availableTracks.contains(LessonTrackConstants.science)) ...[
            const SizedBox(width: AppSizes.spacing8),
            _FilterChipItem(
              label: LessonTrack.science.labelKm,
              icon: LessonTrack.science.icon,
              isSelected: selectedTrack == LessonTrackConstants.science,
              onTap: () => onTrackSelected(LessonTrackConstants.science),
              isDark: isDark,
              accentColor: LessonTrack.science.foregroundColor(context),
            ),
          ],
          if (availableTracks.contains(LessonTrackConstants.social)) ...[
            const SizedBox(width: AppSizes.spacing8),
            _FilterChipItem(
              label: LessonTrack.social.labelKm,
              icon: LessonTrack.social.icon,
              isSelected: selectedTrack == LessonTrackConstants.social,
              onTap: () => onTrackSelected(LessonTrackConstants.social),
              isDark: isDark,
              accentColor: LessonTrack.social.foregroundColor(context),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    this.accentColor,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    // Primary brand color #032EA1 is used for active state
    final selectedBg = AppColors.primary;
    const selectedFg = Colors.white;

    final unselectedBg = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF1F5F9);
    final unselectedBorder = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final unselectedFg = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF475569);

    return Material(
      color: isSelected ? selectedBg : unselectedBg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacing12,
            vertical: 6.0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? selectedBg : unselectedBorder,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? selectedFg : (accentColor ?? unselectedFg),
              ),
              const SizedBox(width: 6.0),
              Text(
                label,
                style: GoogleFonts.battambang(
                  textStyle: TextStyle(
                    color: isSelected ? selectedFg : unselectedFg,
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

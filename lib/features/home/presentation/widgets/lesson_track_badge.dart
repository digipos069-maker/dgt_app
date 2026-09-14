import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/models/lesson_track.dart';

/// A badge chip to display the curriculum track ([LessonTrack.science] or [LessonTrack.social]).
///
/// If [trackType] is null or unknown, this widget renders nothing.
class LessonTrackBadge extends StatelessWidget {
  const LessonTrackBadge({
    required this.trackType,
    this.compact = false,
    super.key,
  });

  final int? trackType;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final track = LessonTrack.fromId(trackType);
    if (track == null) return const SizedBox.shrink();

    final bg = track.backgroundColor(context);
    final border = track.borderColor(context);
    final fg = track.foregroundColor(context);

    final textStyle = GoogleFonts.battambang(
      textStyle: TextStyle(
        color: fg,
        fontSize: compact ? 11.0 : 12.0,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6.0 : AppSizes.spacing8,
        vertical: compact ? 2.0 : 3.5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            track.icon,
            size: compact ? 12.0 : 14.0,
            color: fg,
          ),
          const SizedBox(width: AppSizes.spacing4),
          Text(
            track.labelKm,
            style: textStyle,
          ),
        ],
      ),
    );
  }
}

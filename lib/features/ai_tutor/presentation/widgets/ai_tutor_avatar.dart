import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';

/// The AI tutor's avatar: the app logo in a white circle (readable in dark mode too).
class AiTutorAvatar extends StatelessWidget {
  const AiTutorAvatar({this.size = 40, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // The logo file is large (1464px); decode it at the size actually shown.
    final cacheSize = (size * MediaQuery.devicePixelRatioOf(context)).round();

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: ClipOval(
        child: Image.asset(
          AppAssets.logo,
          fit: BoxFit.contain,
          cacheWidth: cacheSize,
          cacheHeight: cacheSize,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, _, _) =>
              Icon(Icons.school_rounded, size: size * 0.6, color: colors.primary),
        ),
      ),
    );
  }
}

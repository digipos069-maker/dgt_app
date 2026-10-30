import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';

/// Avatar sizes used by the AI tutor (welcome, lesson card, chat messages).
const _avatarSizes = [64.0, 44.0, 28.0];

/// The logo file is large (1464px), so it is decoded at the size actually shown.
/// Both the avatar and [precacheAiTutorAvatars] use this, so the cache is shared.
ImageProvider _logoProvider(BuildContext context, double size) {
  final pixels = (size * MediaQuery.devicePixelRatioOf(context)).round();
  return ResizeImage(const AssetImage(AppAssets.logo), width: pixels, height: pixels);
}

/// Decodes the logo for every avatar size ahead of time (called by the skeleton),
/// so avatars appear instantly instead of popping in.
void precacheAiTutorAvatars(BuildContext context) {
  for (final size in _avatarSizes) {
    precacheImage(_logoProvider(context, size), context, onError: (_, _) {});
  }
}

/// The AI tutor's avatar: the app logo in a white circle (readable in dark mode too).
class AiTutorAvatar extends StatelessWidget {
  const AiTutorAvatar({this.size = 40, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
        child: Image(
          image: _logoProvider(context, size),
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          // Fade in if the logo wasn't decoded yet (instant when precached).
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: child,
            );
          },
          errorBuilder: (_, _, _) =>
              Icon(Icons.school_rounded, size: size * 0.6, color: colors.primary),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ai_tutor_controller.dart';

/// Longest time the AI tutor skeleton is shown, even on a slow network.
const aiTutorSkeletonMaxWait = Duration(seconds: 3);

/// Completes when the AI tutor page can be shown without layout jumps:
/// the token allowance has loaded (or failed) and the Khmer font is ready.
/// Never waits longer than [aiTutorSkeletonMaxWait].
final aiTutorPageReadyProvider = FutureProvider.autoDispose<void>((ref) async {
  // Keep the usage provider alive while we wait for it, without rebuilding
  // this provider every time usage changes after an answer.
  ref.watch(aiTutorUsageProvider.select((_) => 0));

  Future<void> ignoreErrors(Future<Object?> future) =>
      future.then<void>((_) {}, onError: (Object _) {});

  final everythingLoaded = Future.wait([
    ignoreErrors(ref.read(aiTutorUsageProvider.future)),
    ignoreErrors(GoogleFonts.pendingFonts([GoogleFonts.battambang()])),
  ]);

  await Future.any([everythingLoaded, Future<void>.delayed(aiTutorSkeletonMaxWait)]);
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../localization/app_localizations.dart';
import '../../../../theme/theme_controller.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return IconButton(
      tooltip: context.l10n.text('toggleTheme'),
      onPressed: ref.read(themeControllerProvider.notifier).toggleTheme,
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
    );
  }
}

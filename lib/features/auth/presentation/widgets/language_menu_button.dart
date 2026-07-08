import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../localization/app_localizations.dart';
import '../../../../localization/language_controller.dart';

class LanguageMenuButton extends ConsumerWidget {
  const LanguageMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageControllerProvider);

    return PopupMenuButton<Locale>(
      tooltip: context.l10n.text('language'),
      icon: const Icon(Icons.language),
      initialValue: locale,
      onSelected: ref.read(languageControllerProvider.notifier).setLocale,
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: const Locale('en'),
            child: Text(context.l10n.text('english')),
          ),
          PopupMenuItem(
            value: const Locale('km'),
            child: Text(context.l10n.text('khmer')),
          ),
        ];
      },
    );
  }
}

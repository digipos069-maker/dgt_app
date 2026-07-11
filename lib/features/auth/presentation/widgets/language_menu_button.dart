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
      initialValue: locale,
      onSelected: ref.read(languageControllerProvider.notifier).setLocale,
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: const Locale('en'),
            child: _LanguageOption(
              flag: _flagFor('en'),
              label: context.l10n.text('english'),
            ),
          ),
          PopupMenuItem(
            value: const Locale('km'),
            child: _LanguageOption(
              flag: _flagFor('km'),
              label: context.l10n.text('khmer'),
            ),
          ),
        ];
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_flagFor(locale.languageCode)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }

  String _flagFor(String languageCode) {
    return switch (languageCode) {
      'km' => '🇰🇭',
      _ => '🇺🇸',
    };
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({required this.flag, required this.label});

  final String flag;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(flag, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Text(label),
      ],
    );
  }
}

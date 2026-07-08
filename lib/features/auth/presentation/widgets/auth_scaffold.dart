import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import 'language_menu_button.dart';
import 'theme_toggle_button.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.text('appName')),
        actions: const [
          LanguageMenuButton(),
          ThemeToggleButton(),
          SizedBox(width: AppSizes.spacing8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.spacing24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxFormWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing8),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing32),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

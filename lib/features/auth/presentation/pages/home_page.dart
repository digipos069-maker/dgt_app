import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../application/auth_controller.dart';
import '../widgets/language_menu_button.dart';
import '../widgets/theme_toggle_button.dart';
import 'login_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const routeName = 'home';
  static const routePath = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = switch (ref.watch(authControllerProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.text('homeTitle')),
        actions: const [
          LanguageMenuButton(),
          ThemeToggleButton(),
          SizedBox(width: AppSizes.spacing8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.text('homeMessage'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (user != null) ...[
                const SizedBox(height: AppSizes.spacing12),
                Text(user.email),
              ],
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(authControllerProvider.notifier).logout();
                  context.goNamed(LoginPage.routeName);
                },
                icon: const Icon(Icons.logout),
                label: Text(l10n.text('logout')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../../home/presentation/widgets/main_bottom_navigation.dart';
import '../../application/auth_controller.dart';
import '../widgets/language_menu_button.dart';
import '../widgets/profile_body.dart';
import '../widgets/theme_toggle_button.dart';
import 'home_page.dart';
import 'login_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static const routeName = 'profile';
  static const routePath = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = switch (ref.watch(authControllerProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.goNamed(HomePage.routeName),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(context.l10n.text('profileTitle')),
        actions: [
          const LanguageMenuButton(),
          const ThemeToggleButton(),
          IconButton(
            tooltip: context.l10n.text('notifications'),
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
          const SizedBox(width: AppSizes.spacing4),
        ],
      ),
      body: ProfileBody(
        user: user,
        onLogout: () {
          ref.read(authControllerProvider.notifier).logout();
          context.goNamed(LoginPage.routeName);
        },
      ),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 0),
    );
  }
}

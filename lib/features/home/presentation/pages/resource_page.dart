import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/scroll_hiding_header.dart';
import '../../../../localization/app_localizations.dart';
import '../../../auth/presentation/widgets/language_menu_button.dart';
import '../../../auth/presentation/widgets/theme_toggle_button.dart';
import '../widgets/main_bottom_navigation.dart';
import '../widgets/resource_body.dart';

class ResourcePage extends StatelessWidget {
  const ResourcePage({super.key});

  static const routeName = 'resource';
  static const routePath = '/resource';

  @override
  Widget build(BuildContext context) {
    return ScrollHidingHeaderScaffold(
      header: AppBar(
        title: Text(context.l10n.text('menuResource')),
        actions: const [
          LanguageMenuButton(),
          ThemeToggleButton(),
          SizedBox(width: AppSizes.spacing8),
        ],
      ),
      body: const ResourceBody(),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 4),
    );
  }
}

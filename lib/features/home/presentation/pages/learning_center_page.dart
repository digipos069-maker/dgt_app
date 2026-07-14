import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../../auth/presentation/widgets/language_menu_button.dart';
import '../../../auth/presentation/widgets/theme_toggle_button.dart';
import '../widgets/learning_center_body.dart';
import '../widgets/main_bottom_navigation.dart';

class LearningCenterPage extends StatelessWidget {
  const LearningCenterPage({super.key});

  static const routeName = 'learning-center';
  static const routePath = '/learning-center';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.text('menuLearningCenter')),
        actions: const [
          LanguageMenuButton(),
          ThemeToggleButton(),
          SizedBox(width: AppSizes.spacing8),
        ],
      ),
      body: const LearningCenterBody(),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 1),
    );
  }
}

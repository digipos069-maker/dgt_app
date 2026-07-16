import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/scroll_hiding_header.dart';
import '../../../../localization/app_localizations.dart';
import '../../../auth/presentation/widgets/language_menu_button.dart';
import '../../../auth/presentation/widgets/theme_toggle_button.dart';
import '../widgets/grade_list_body.dart';
import '../widgets/main_bottom_navigation.dart';

class GradeListPage extends StatelessWidget {
  const GradeListPage({super.key});

  static const routeName = 'grade-list';
  static const routePath = '/grades';

  @override
  Widget build(BuildContext context) {
    return ScrollHidingHeaderScaffold(
      header: AppBar(
        title: Text(context.l10n.text('gradeListTitle')),
        actions: const [
          LanguageMenuButton(),
          ThemeToggleButton(),
          SizedBox(width: AppSizes.spacing8),
        ],
      ),
      body: const GradeListBody(),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 1),
    );
  }
}

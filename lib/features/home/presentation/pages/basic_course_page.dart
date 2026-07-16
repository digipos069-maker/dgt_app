import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/scroll_hiding_header.dart';
import '../../../../localization/app_localizations.dart';
import '../../../auth/presentation/widgets/language_menu_button.dart';
import '../../../auth/presentation/widgets/theme_toggle_button.dart';
import '../widgets/basic_course_body.dart';
import '../widgets/main_bottom_navigation.dart';

class BasicCoursePage extends StatelessWidget {
  const BasicCoursePage({super.key});

  static const routeName = 'basic-course';
  static const routePath = '/basic-course';

  @override
  Widget build(BuildContext context) {
    return ScrollHidingHeaderScaffold(
      header: AppBar(
        title: Text(context.l10n.text('menuBasicCourse')),
        actions: const [
          LanguageMenuButton(),
          ThemeToggleButton(),
          SizedBox(width: AppSizes.spacing8),
        ],
      ),
      body: const BasicCourseBody(),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 2),
    );
  }
}

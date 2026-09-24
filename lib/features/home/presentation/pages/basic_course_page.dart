import 'package:flutter/material.dart';

import '../../../../core/widgets/scroll_hiding_header.dart';
import '../../../../localization/app_localizations.dart';
import '../widgets/basic_course_body.dart';
import '../widgets/main_bottom_navigation.dart';

class BasicCoursePage extends StatelessWidget {
  const BasicCoursePage({super.key});

  static const routeName = 'basic-course';
  static const routePath = '/basic-course';

  @override
  Widget build(BuildContext context) {
    return ScrollHidingHeaderScaffold(
      header: AppBar(title: Text(context.l10n.text('menuBasicCourse'))),
      body: const BasicCourseBody(),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 2),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/widgets/scroll_hiding_header.dart';
import '../../../../localization/app_localizations.dart';
import '../widgets/grade_list_body.dart';
import '../widgets/main_bottom_navigation.dart';

class GradeListPage extends StatelessWidget {
  const GradeListPage({super.key});

  static const routeName = 'grade-list';
  static const routePath = '/grades';

  @override
  Widget build(BuildContext context) {
    return ScrollHidingHeaderScaffold(
      header: AppBar(title: Text(context.l10n.text('gradeListTitle'))),
      body: const GradeListBody(),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 1),
    );
  }
}

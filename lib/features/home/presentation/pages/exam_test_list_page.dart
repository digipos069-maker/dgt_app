import 'package:flutter/material.dart';

import '../../../../localization/app_localizations.dart';
import '../widgets/exam_test_list_body.dart';
import '../widgets/main_bottom_navigation.dart';

class ExamTestListPage extends StatelessWidget {
  const ExamTestListPage({super.key});

  static const routeName = 'exam-tests';
  static const routePath = '/resource/tests';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.text('examTestTitle'))),
      body: const ExamTestListBody(),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 4),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../localization/app_localizations.dart';
import '../widgets/main_bottom_navigation.dart';
import '../widgets/my_study_body.dart';

/// "ការសិក្សារបស់ខ្ញុំ" — the student's saved exam-test results.
class MyStudyPage extends StatelessWidget {
  const MyStudyPage({super.key});

  static const routeName = 'my-study';
  static const routePath = '/profile/my-study';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/profile'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(context.l10n.text('myStudyTitle')),
      ),
      body: const MyStudyBody(),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 0),
    );
  }
}

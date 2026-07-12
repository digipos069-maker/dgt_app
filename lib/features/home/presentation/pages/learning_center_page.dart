import 'package:flutter/material.dart';

import '../widgets/coming_soon_scaffold.dart';

class LearningCenterPage extends StatelessWidget {
  const LearningCenterPage({super.key});

  static const routeName = 'learning-center';
  static const routePath = '/learning-center';

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScaffold(
      titleKey: 'menuLearningCenter',
      selectedIndex: 1,
    );
  }
}

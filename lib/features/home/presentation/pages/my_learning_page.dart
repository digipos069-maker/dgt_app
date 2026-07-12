import 'package:flutter/material.dart';

import '../widgets/coming_soon_scaffold.dart';

class MyLearningPage extends StatelessWidget {
  const MyLearningPage({super.key});

  static const routeName = 'my-learning';
  static const routePath = '/my-learning';

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScaffold(
      titleKey: 'menuMyLearning',
      selectedIndex: 2,
    );
  }
}

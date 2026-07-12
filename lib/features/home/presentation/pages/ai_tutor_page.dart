import 'package:flutter/material.dart';

import '../widgets/coming_soon_scaffold.dart';

class AiTutorPage extends StatelessWidget {
  const AiTutorPage({super.key});

  static const routeName = 'ai-tutor';
  static const routePath = '/ai-tutor';

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScaffold(titleKey: 'menuAiTutor', selectedIndex: 3);
  }
}

import 'package:flutter/material.dart';

import '../widgets/main_bottom_navigation.dart';
import '../widgets/resource_years_body.dart';

class ResourceYearsPage extends StatelessWidget {
  const ResourceYearsPage({required this.examId, super.key});

  static const routeName = 'resource-years';
  static const routePath = '/resource/:examId/years';

  final String examId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResourceYearsBody(examId: examId),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 4),
    );
  }
}

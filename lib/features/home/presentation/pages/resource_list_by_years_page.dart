import 'package:flutter/material.dart';

import '../widgets/main_bottom_navigation.dart';
import '../widgets/resource_list_by_years_body.dart';

class ResourceListByYearsPage extends StatelessWidget {
  const ResourceListByYearsPage({
    required this.examId,
    required this.year,
    super.key,
  });

  static const routeName = 'resource-list-by-years';
  static const routePath = '/resource/:examId/years/:year';

  final String examId;
  final int year;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResourceListByYearsBody(examId: examId, year: year),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 4),
    );
  }
}

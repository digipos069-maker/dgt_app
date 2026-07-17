import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'grade_list_page.dart';
import '../widgets/learning_center_body.dart';
import '../widgets/main_bottom_navigation.dart';

class LearningCenterPage extends StatelessWidget {
  const LearningCenterPage({
    this.gradeId,
    this.gradeNumber,
    this.subjectId = 1,
    super.key,
  });

  static const routeName = 'learning-center';
  static const routePath = '/learning-center';

  final int? gradeId;
  final int? gradeNumber;
  final int subjectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LearningCenterBody(
        gradeId: gradeId,
        gradeNumber: gradeNumber,
        initialSubjectId: subjectId,
        onBack: () => context.goNamed(GradeListPage.routeName),
      ),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 1),
    );
  }
}

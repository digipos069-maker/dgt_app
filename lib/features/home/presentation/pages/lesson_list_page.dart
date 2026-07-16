import 'package:flutter/material.dart';

import '../widgets/lesson_list_body.dart';
import '../widgets/main_bottom_navigation.dart';

class LessonListPage extends StatelessWidget {
  const LessonListPage({
    required this.courseId,
    this.gradeId,
    this.gradeNumber,
    super.key,
  });

  static const routeName = 'lesson-list';
  static const routePath = '/learning-center/:courseId/lessons';

  final String courseId;
  final int? gradeId;
  final int? gradeNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LessonListBody(
        courseId: courseId,
        gradeId: gradeId,
        gradeNumber: gradeNumber,
      ),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 1),
    );
  }
}

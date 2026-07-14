import 'package:flutter/material.dart';

import '../widgets/lesson_detail_body.dart';
import '../widgets/main_bottom_navigation.dart';

class LessonDetailPage extends StatelessWidget {
  const LessonDetailPage({
    required this.courseId,
    required this.lessonId,
    super.key,
  });

  static const routeName = 'lesson-detail';
  static const routePath = '/learning-center/:courseId/lessons/:lessonId';

  final String courseId;
  final String lessonId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LessonDetailBody(courseId: courseId, lessonId: lessonId),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 1),
    );
  }
}

import 'package:flutter/material.dart';

import '../widgets/basic_lesson_detail_body.dart';
import '../widgets/main_bottom_navigation.dart';

class BasicLessonDetailPage extends StatelessWidget {
  const BasicLessonDetailPage({
    required this.courseId,
    required this.lessonId,
    super.key,
  });

  static const routeName = 'basic-lesson-detail';
  static const routePath = '/basic-course/:courseId/lessons/:lessonId';

  final String courseId;
  final String lessonId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BasicLessonDetailBody(courseId: courseId, lessonId: lessonId),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 2),
    );
  }
}

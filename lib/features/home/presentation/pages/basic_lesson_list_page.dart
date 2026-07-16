import 'package:flutter/material.dart';

import '../widgets/basic_lesson_list_body.dart';
import '../widgets/main_bottom_navigation.dart';

class BasicLessonListPage extends StatelessWidget {
  const BasicLessonListPage({required this.courseId, super.key});

  static const routeName = 'basic-lesson-list';
  static const routePath = '/basic-course/:courseId/lessons';

  final String courseId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BasicLessonListBody(courseId: courseId),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 2),
    );
  }
}

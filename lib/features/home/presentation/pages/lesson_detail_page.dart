import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/lesson_detail_body.dart';
import '../widgets/main_bottom_navigation.dart';
import 'lesson_list_page.dart';

class LessonDetailPage extends StatelessWidget {
  const LessonDetailPage({
    required this.courseId,
    required this.lessonId,
    this.gradeId,
    this.gradeNumber,
    this.subjectId,
    super.key,
  });

  static const routeName = 'lesson-detail';
  static const routePath = '/learning-center/:courseId/lessons/:lessonId';

  final String courseId;
  final String lessonId;
  final int? gradeId;
  final int? gradeNumber;
  final int? subjectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LessonDetailBody(
        courseId: courseId,
        lessonId: lessonId,
        onBack: () => context.goNamed(
          LessonListPage.routeName,
          pathParameters: {'courseId': courseId},
          queryParameters: {
            if (gradeId != null) 'gradeId': gradeId.toString(),
            if (gradeNumber != null) 'gradeNumber': gradeNumber.toString(),
            if (subjectId != null) 'subjectId': subjectId.toString(),
          },
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 1),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/main_bottom_navigation.dart';
import '../widgets/quiz/quiz_by_lesson_body.dart';

class QuizByLessonPage extends StatelessWidget {
  const QuizByLessonPage({
    required this.lessonId,
    this.size = 15,
    super.key,
  });

  static const routeName = 'quiz-by-lesson';
  static const routePath = '/quiz-by-lesson/:lessonId';

  final int lessonId;
  final int size;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: QuizByLessonBody(
          lessonId: lessonId,
          size: size,
          onBack: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else if (context.canPop()) {
              context.pop();
            } else {
              context.go('/learning-center');
            }
          },
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 1),
    );
  }
}

import 'package:flutter/material.dart';

import '../widgets/exam_test_detail_body.dart';

class ExamTestDetailPage extends StatelessWidget {
  const ExamTestDetailPage({required this.testId, super.key});

  static const routeName = 'exam-test-detail';
  static const routePath = '/resource/tests/:testId';

  static String pathFor(String testId) =>
      '/resource/tests/${Uri.encodeComponent(testId)}';

  final String testId;

  @override
  Widget build(BuildContext context) {
    // No bottom navigation here on purpose: taking a test is a focus mode,
    // and leaving mid-test is guarded by a confirmation in the body.
    return ExamTestDetailBody(testId: testId);
  }
}

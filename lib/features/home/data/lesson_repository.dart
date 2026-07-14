import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/lesson_model.dart';

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  return const LessonRepository();
});

class LessonRepository {
  const LessonRepository();

  Future<CourseLessonBundle> fetchLessons(String courseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _mockBundles[courseId] ?? _mockBundles['algebra']!;
  }

  static const _mockBundles = {
    'algebra': CourseLessonBundle(
      courseId: 'algebra',
      appBarTitleKey: 'chapterAlgebra',
      titleKey: 'lessonBundleAlgebraTitle',
      descriptionKey: 'lessonBundleAlgebraDescription',
      lessons: [
        LessonModel(
          id: 'linear-equations',
          titleKey: 'lessonLinearEquations',
          type: LessonType.video,
          durationMinutes: 12,
          isCompleted: true,
        ),
        LessonModel(
          id: 'quadratic-formula',
          titleKey: 'lessonQuadraticFormula',
          type: LessonType.reading,
          durationMinutes: 15,
          isCompleted: true,
        ),
        LessonModel(
          id: 'polynomials',
          titleKey: 'lessonPolynomials',
          type: LessonType.locked,
          durationMinutes: 18,
          isCompleted: false,
        ),
      ],
    ),
    'force-motion': CourseLessonBundle(
      courseId: 'force-motion',
      appBarTitleKey: 'chapterForceMotion',
      titleKey: 'lessonBundlePhysicsTitle',
      descriptionKey: 'lessonBundlePhysicsDescription',
      lessons: [
        LessonModel(
          id: 'newtons-laws',
          titleKey: 'lessonNewtonsLaws',
          type: LessonType.video,
          durationMinutes: 10,
          isCompleted: true,
        ),
        LessonModel(
          id: 'force-diagrams',
          titleKey: 'lessonForceDiagrams',
          type: LessonType.reading,
          durationMinutes: 14,
          isCompleted: false,
        ),
        LessonModel(
          id: 'motion-practice',
          titleKey: 'lessonMotionPractice',
          type: LessonType.locked,
          durationMinutes: 20,
          isCompleted: false,
        ),
      ],
    ),
    'narrative': CourseLessonBundle(
      courseId: 'narrative',
      appBarTitleKey: 'chapterNarrative',
      titleKey: 'lessonBundleNarrativeTitle',
      descriptionKey: 'lessonBundleNarrativeDescription',
      lessons: [
        LessonModel(
          id: 'story-elements',
          titleKey: 'lessonStoryElements',
          type: LessonType.video,
          durationMinutes: 9,
          isCompleted: true,
        ),
        LessonModel(
          id: 'plot-structure',
          titleKey: 'lessonPlotStructure',
          type: LessonType.reading,
          durationMinutes: 13,
          isCompleted: false,
        ),
        LessonModel(
          id: 'writing-practice',
          titleKey: 'lessonWritingPractice',
          type: LessonType.locked,
          durationMinutes: 17,
          isCompleted: false,
        ),
      ],
    ),
  };
}

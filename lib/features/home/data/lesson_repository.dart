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

  Future<LessonDetailModel> fetchLessonDetail({
    required String courseId,
    required String lessonId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _mockDetails['$courseId/$lessonId'] ??
        _mockDetails['algebra/$lessonId'] ??
        _mockDetails['algebra/linear-equations']!;
  }

  static const _mockBundles = {
    'algebra': CourseLessonBundle(
      courseId: 'algebra',
      appBarTitleKey: 'chapterAlgebra',
      titleKey: 'lessonBundleAlgebraTitle',
      descriptionKey: 'lessonBundleAlgebraDescription',
      lessons: [
        LessonModel(
          courseId: 'algebra',
          id: 'linear-equations',
          titleKey: 'lessonLinearEquations',
          type: LessonType.video,
          durationMinutes: 12,
          isCompleted: false,
        ),
        LessonModel(
          courseId: 'algebra',
          id: 'quadratic-formula',
          titleKey: 'lessonQuadraticFormula',
          type: LessonType.reading,
          durationMinutes: 15,
          isCompleted: false,
        ),
        LessonModel(
          courseId: 'algebra',
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
          courseId: 'force-motion',
          id: 'newtons-laws',
          titleKey: 'lessonNewtonsLaws',
          type: LessonType.video,
          durationMinutes: 10,
          isCompleted: false,
        ),
        LessonModel(
          courseId: 'force-motion',
          id: 'force-diagrams',
          titleKey: 'lessonForceDiagrams',
          type: LessonType.reading,
          durationMinutes: 14,
          isCompleted: false,
        ),
        LessonModel(
          courseId: 'force-motion',
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
          courseId: 'narrative',
          id: 'story-elements',
          titleKey: 'lessonStoryElements',
          type: LessonType.video,
          durationMinutes: 9,
          isCompleted: true,
        ),
        LessonModel(
          courseId: 'narrative',
          id: 'plot-structure',
          titleKey: 'lessonPlotStructure',
          type: LessonType.reading,
          durationMinutes: 13,
          isCompleted: false,
        ),
        LessonModel(
          courseId: 'narrative',
          id: 'writing-practice',
          titleKey: 'lessonWritingPractice',
          type: LessonType.locked,
          durationMinutes: 17,
          isCompleted: false,
        ),
      ],
    ),
  };

  static const _mockDetails = {
    'algebra/linear-equations': LessonDetailModel(
      courseId: 'algebra',
      lessonId: 'linear-equations',
      titleKey: 'lessonLinearEquations',
      subjectKey: 'lessonDetailSubjectMath',
      moduleKey: 'lessonDetailModuleOne',
      descriptionKey: 'lessonLinearEquationsDescription',
      durationLabel: '12:45',
      quizTitleKey: 'lessonQuizTitle',
      quizSubtitleKey: 'lessonQuizSubtitleLinear',
      questions: [
        QuizQuestionModel(
          quizId: 1,
          id: 'q1',
          questionKey: 'quizLinearQuestionOne',
          options: [
            QuizOptionModel(id: 'A', labelKey: 'quizLinearQ1A'),
            QuizOptionModel(id: 'B', labelKey: 'quizLinearQ1B'),
            QuizOptionModel(id: 'C', labelKey: 'quizLinearQ1C'),
            QuizOptionModel(id: 'D', labelKey: 'quizLinearQ1D'),
          ],
        ),
        QuizQuestionModel(
          quizId: 1,
          id: 'q2',
          questionKey: 'quizLinearQuestionTwo',
          options: [
            QuizOptionModel(id: 'A', labelKey: 'quizLinearQ2A'),
            QuizOptionModel(id: 'B', labelKey: 'quizLinearQ2B'),
            QuizOptionModel(id: 'C', labelKey: 'quizLinearQ2C'),
            QuizOptionModel(id: 'D', labelKey: 'quizLinearQ2D'),
          ],
        ),
      ],
    ),
    'algebra/quadratic-formula': LessonDetailModel(
      courseId: 'algebra',
      lessonId: 'quadratic-formula',
      titleKey: 'lessonQuadraticFormula',
      subjectKey: 'lessonDetailSubjectMath',
      moduleKey: 'lessonDetailModuleOne',
      descriptionKey: 'lessonQuadraticFormulaDescription',
      durationLabel: '15:00',
      quizTitleKey: 'lessonQuizTitle',
      quizSubtitleKey: 'lessonQuizSubtitleQuadratic',
      questions: [
        QuizQuestionModel(
          quizId: 1,
          id: 'q1',
          questionKey: 'quizQuadraticQuestionOne',
          options: [
            QuizOptionModel(id: 'A', labelKey: 'quizQuadraticQ1A'),
            QuizOptionModel(id: 'B', labelKey: 'quizQuadraticQ1B'),
            QuizOptionModel(id: 'C', labelKey: 'quizQuadraticQ1C'),
            QuizOptionModel(id: 'D', labelKey: 'quizQuadraticQ1D'),
          ],
        ),
      ],
    ),
    'force-motion/newtons-laws': LessonDetailModel(
      courseId: 'force-motion',
      lessonId: 'newtons-laws',
      titleKey: 'lessonNewtonsLaws',
      subjectKey: 'subjectPhysics',
      moduleKey: 'lessonDetailModuleOne',
      descriptionKey: 'lessonNewtonsLawsDescription',
      durationLabel: '10:30',
      quizTitleKey: 'lessonQuizTitle',
      quizSubtitleKey: 'lessonQuizSubtitlePhysics',
      questions: [
        QuizQuestionModel(
          quizId: 1,
          id: 'q1',
          questionKey: 'quizPhysicsQuestionOne',
          options: [
            QuizOptionModel(id: 'A', labelKey: 'quizPhysicsQ1A'),
            QuizOptionModel(id: 'B', labelKey: 'quizPhysicsQ1B'),
            QuizOptionModel(id: 'C', labelKey: 'quizPhysicsQ1C'),
            QuizOptionModel(id: 'D', labelKey: 'quizPhysicsQ1D'),
          ],
        ),
      ],
    ),
    'force-motion/force-diagrams': LessonDetailModel(
      courseId: 'force-motion',
      lessonId: 'force-diagrams',
      titleKey: 'lessonForceDiagrams',
      subjectKey: 'subjectPhysics',
      moduleKey: 'lessonDetailModuleOne',
      descriptionKey: 'lessonForceDiagramsDescription',
      durationLabel: '14:00',
      quizTitleKey: 'lessonQuizTitle',
      quizSubtitleKey: 'lessonQuizSubtitlePhysics',
      questions: [
        QuizQuestionModel(
          quizId: 1,
          id: 'q1',
          questionKey: 'quizPhysicsQuestionOne',
          options: [
            QuizOptionModel(id: 'A', labelKey: 'quizPhysicsQ1A'),
            QuizOptionModel(id: 'B', labelKey: 'quizPhysicsQ1B'),
            QuizOptionModel(id: 'C', labelKey: 'quizPhysicsQ1C'),
            QuizOptionModel(id: 'D', labelKey: 'quizPhysicsQ1D'),
          ],
        ),
      ],
    ),
    'narrative/story-elements': LessonDetailModel(
      courseId: 'narrative',
      lessonId: 'story-elements',
      titleKey: 'lessonStoryElements',
      subjectKey: 'subjectLiterature',
      moduleKey: 'lessonDetailModuleOne',
      descriptionKey: 'lessonStoryElementsDescription',
      durationLabel: '09:00',
      quizTitleKey: 'lessonQuizTitle',
      quizSubtitleKey: 'lessonQuizSubtitleNarrative',
      questions: [
        QuizQuestionModel(
          quizId: 1,
          id: 'q1',
          questionKey: 'quizNarrativeQuestionOne',
          options: [
            QuizOptionModel(id: 'A', labelKey: 'quizNarrativeQ1A'),
            QuizOptionModel(id: 'B', labelKey: 'quizNarrativeQ1B'),
            QuizOptionModel(id: 'C', labelKey: 'quizNarrativeQ1C'),
            QuizOptionModel(id: 'D', labelKey: 'quizNarrativeQ1D'),
          ],
        ),
      ],
    ),
    'narrative/plot-structure': LessonDetailModel(
      courseId: 'narrative',
      lessonId: 'plot-structure',
      titleKey: 'lessonPlotStructure',
      subjectKey: 'subjectLiterature',
      moduleKey: 'lessonDetailModuleOne',
      descriptionKey: 'lessonPlotStructureDescription',
      durationLabel: '13:00',
      quizTitleKey: 'lessonQuizTitle',
      quizSubtitleKey: 'lessonQuizSubtitleNarrative',
      questions: [
        QuizQuestionModel(
          quizId: 1,
          id: 'q1',
          questionKey: 'quizNarrativeQuestionOne',
          options: [
            QuizOptionModel(id: 'A', labelKey: 'quizNarrativeQ1A'),
            QuizOptionModel(id: 'B', labelKey: 'quizNarrativeQ1B'),
            QuizOptionModel(id: 'C', labelKey: 'quizNarrativeQ1C'),
            QuizOptionModel(id: 'D', labelKey: 'quizNarrativeQ1D'),
          ],
        ),
      ],
    ),
  };
}

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
        QuizQuestionModel.matching(
          id: 'q3_matching',
          matchingData: MatchingQuizData(
            stems: [
              QuizStem(id: 's1', text: 'Variable x'),
              QuizStem(id: 's2', text: 'Constant 5'),
              QuizStem(id: 's3', text: 'Coefficient 2'),
            ],
            options: [
              MatchingOption(id: 'o1', text: 'Unknown value to solve'),
              MatchingOption(id: 'o2', text: 'Fixed numeric value'),
              MatchingOption(id: 'o3', text: 'Multiplicative factor of x'),
            ],
            description: 'Match algebraic terms with their definitions',
            correctMatches: {
              's1': 'o1',
              's2': 'o2',
              's3': 'o3',
            },
          ),
        ),
        QuizQuestionModel.dragAndDrop(
          id: 'q4_drag_drop',
          dragAndDropData: DragAndDropQuizData(
            correct: '2H₂O',
            draggables: [
              '2H₂O',
              'H₂',
              'O₂',
            ],
            droppableId: 'water-molecule',
            prompt: 'Drag the balanced water molecule product into the slot:',
          ),
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
        QuizQuestionModel.matching(
          id: 'q2_quad_matching',
          matchingData: MatchingQuizData(
            stems: [
              QuizStem(id: 's1', text: 'b² - 4ac > 0'),
              QuizStem(id: 's2', text: 'b² - 4ac = 0'),
              QuizStem(id: 's3', text: 'b² - 4ac < 0'),
            ],
            options: [
              MatchingOption(id: 'o1', text: 'Two distinct real roots'),
              MatchingOption(id: 'o2', text: 'One repeated real root'),
              MatchingOption(id: 'o3', text: 'Two complex conjugate roots'),
            ],
            description: 'Match discriminant values with their root nature',
            correctMatches: {'s1': 'o1', 's2': 'o2', 's3': 'o3'},
          ),
        ),
        QuizQuestionModel.dragAndDrop(
          id: 'q3_quad_drag',
          dragAndDropData: DragAndDropQuizData(
            correct: 'b² - 4ac',
            draggables: ['b² - 4ac', '2a', '-b ± √D'],
            droppableId: 'discriminant-slot',
            prompt: 'Drag the quadratic discriminant formula into the target:',
          ),
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
        QuizQuestionModel.matching(
          id: 'q2_physics_matching',
          matchingData: MatchingQuizData(
            stems: [
              QuizStem(id: 's1', text: "Newton's 1st Law"),
              QuizStem(id: 's2', text: "Newton's 2nd Law"),
              QuizStem(id: 's3', text: "Newton's 3rd Law"),
            ],
            options: [
              MatchingOption(id: 'o1', text: 'Inertia: object stays at rest or in uniform motion'),
              MatchingOption(id: 'o2', text: 'Force equals mass times acceleration (F = ma)'),
              MatchingOption(id: 'o3', text: 'For every action, equal and opposite reaction'),
            ],
            description: "Match Newton's laws with their physical meanings",
            correctMatches: {'s1': 'o1', 's2': 'o2', 's3': 'o3'},
          ),
        ),
        QuizQuestionModel.dragAndDrop(
          id: 'q3_physics_drag',
          dragAndDropData: DragAndDropQuizData(
            correct: 'F = ma',
            draggables: ['F = ma', 'v = d/t', 'W = F·d'],
            droppableId: 'second-law-slot',
            prompt: "Drag the formula for Newton's 2nd Law into the slot:",
          ),
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
        QuizQuestionModel.matching(
          id: 'q2_story_matching',
          matchingData: MatchingQuizData(
            stems: [
              QuizStem(id: 's1', text: 'Exposition'),
              QuizStem(id: 's2', text: 'Climax'),
              QuizStem(id: 's3', text: 'Resolution'),
            ],
            options: [
              MatchingOption(id: 'o1', text: 'Introduces setting and characters'),
              MatchingOption(id: 'o2', text: 'Peak dramatic tension or turning point'),
              MatchingOption(id: 'o3', text: 'Conclusion and untangling of conflict'),
            ],
            description: 'Match narrative plot stages with their roles',
            correctMatches: {'s1': 'o1', 's2': 'o2', 's3': 'o3'},
          ),
        ),
        QuizQuestionModel.dragAndDrop(
          id: 'q3_story_drag',
          dragAndDropData: DragAndDropQuizData(
            correct: 'Exposition',
            draggables: ['Exposition', 'Climax', 'Resolution'],
            droppableId: 'initial-stage',
            prompt: 'Drag the initial stage of a classic story structure:',
          ),
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

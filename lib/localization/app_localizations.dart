import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('km')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _values = <String, Map<String, String>>{
    'en': {
      'appName': 'DGT',
      'welcomeBack': 'Welcome back',
      'createAccount': 'Create account',
      'loginSubtitle': 'Sign in to continue to your learning workspace.',
      'registerSubtitle': 'Create your profile and start learning.',
      'email': 'Email or phone',
      'password': 'Password',
      'username': 'Username',
      'fullName': 'Full name',
      'grade': 'Grade',
      'login': 'Log in',
      'register': 'Register',
      'goToRegister': 'Create an account',
      'goToLogin': 'Already have an account? Log in',
      'emailRequired': 'Email or phone is required',
      'emailInvalid': 'Enter a valid email address or phone number',
      'passwordRequired': 'Password is required',
      'passwordShort': 'Password must be at least 6 characters',
      'usernameRequired': 'Username is required',
      'fullNameRequired': 'Full name is required',
      'gradeRequired': 'Grade is required',
      'gradesLoadFailed': 'Failed to load grades',
      'authFailed': 'Something went wrong. Please try again.',
      'homeTitle': 'Home',
      'homeMessage': 'You are signed in with the mock auth service.',
      'homeSearchHint': 'Search lessons, subjects...',
      'homeContinueLearning': 'Continue Learning',
      'homePopularSubjects': 'Popular Subjects',
      'homeRecommendedLessons': 'Recommended Lessons',
      'homeGreeting': 'Good morning',
      'homeStudentDefault': 'Student',
      'homeTodayPlan':
          'You have 3 lessons planned today. Start with Physics to keep your weekly goal on track.',
      'homeContinueSubject': 'Physics - Grade 11',
      'homeContinueTitle': 'Kinematics',
      'homeContinueDescription':
          'Master motion, velocity, and acceleration with interactive simulations.',
      'homeProgress': 'Progress',
      'homeSubjectMath': 'Math',
      'homeSubjectChemistry': 'Chemistry',
      'homeSubjectBiology': 'Biology',
      'homeSubjectHistory': 'History',
      'homeSubjectPhysics': 'Physics',
      'homeSubjectKhmer': 'Khmer',
      'homeLessonAlgebra': 'Algebra Basics',
      'homeLessonAlgebraSubject': 'Math - Grade 10',
      'homeLessonChemicalBonds': 'Chemical Bonds',
      'homeLessonChemistrySubject': 'Chemistry - Grade 11',
      'homeLessonCellStructure': 'Cell Structure',
      'homeLessonBiologySubject': 'Biology - Grade 9',
      'homeDuration18': '18 min',
      'homeDuration24': '24 min',
      'homeDuration16': '16 min',
      'homeYourProgress': 'Your Progress',
      'homeTotalStudyTime': 'Total Study Time',
      'homeLessonsCompleted': 'Lessons Completed',
      'homeDailyGoal': 'Daily Goal',
      'homeDailyGoalMessage': 'Almost there! Keep going.',
      'logout': 'Log out',
      'language': 'Language',
      'english': 'English',
      'khmer': 'Khmer',
      'toggleTheme': 'Toggle theme',
      'menuHome': 'Home',
      'menuLearningCenter': 'Learning Center',
      'menuBasicCourse': 'Basic Course',
      'menuAiTutor': 'AI Tutor',
      'menuResource': 'Resource',
      'basicCourseLoadFailed': 'Could not load basic courses.',
      'basicCourseEmpty': 'No basic courses are available yet.',
      'basicLessonsTitle': 'Basic lessons',
      'basicLessonLoadFailed': 'Could not load basic lessons.',
      'retry': 'Try again',
      'comingSoon': 'Coming soon',
      'learningCenterHero': 'Discover courses',
      'learningCenterSearchHint': 'Search chapters or subjects...',
      'gradePrefix': 'Grade',
      'subjectMath': 'Mathematics',
      'subjectPhysics': 'Physics',
      'subjectChemistry': 'Chemistry',
      'subjectBiology': 'Biology',
      'subjectLiterature': 'Literature',
      'chapterAlgebra': 'Chapter 1: Algebra foundations',
      'chapterForceMotion': 'Chapter 2: Force and motion',
      'chapterNarrative': 'Chapter 3: Narrative structure',
      'lessonsTitle': 'Lessons',
      'lessonBundleAlgebraTitle': 'Algebra foundations',
      'lessonBundleAlgebraDescription':
          'Build the core skills for algebraic thinking. This chapter covers linear equations, quadratic formulas, and polynomial operations.',
      'lessonBundlePhysicsTitle': 'Force and motion',
      'lessonBundlePhysicsDescription':
          'Understand how force changes motion through practical examples, diagrams, and guided problem solving.',
      'lessonBundleNarrativeTitle': 'Narrative structure',
      'lessonBundleNarrativeDescription':
          'Learn how stories are organized through characters, setting, conflict, plot, and resolution.',
      'lessonLinearEquations': '1.1 Linear equations',
      'lessonQuadraticFormula': '1.2 Quadratic formula',
      'lessonPolynomials': '1.3 Polynomials',
      'lessonNewtonsLaws': "2.1 Newton's laws",
      'lessonForceDiagrams': '2.2 Force diagrams',
      'lessonMotionPractice': '2.3 Motion practice',
      'lessonStoryElements': '3.1 Story elements',
      'lessonPlotStructure': '3.2 Plot structure',
      'lessonWritingPractice': '3.3 Writing practice',
      'lessonTypeVideo': 'Video',
      'lessonTypeReading': 'Reading',
      'lessonTypeLocked': 'Locked',
      'minutesShort': 'min',
      'lessonDetailSubjectMath': 'Mathematics 101',
      'lessonDetailModuleOne': 'Module 1',
      'lessonLinearEquationsDescription':
          'Learn how to solve basic linear equations using addition, subtraction, multiplication, and division. This foundation is important for understanding algebra.',
      'lessonQuadraticFormulaDescription':
          'Learn when and how to apply the quadratic formula to solve second-degree equations clearly and confidently.',
      'lessonNewtonsLawsDescription':
          "Explore Newton's laws of motion and how force, mass, and acceleration connect in real situations.",
      'lessonForceDiagramsDescription':
          'Practice drawing and reading force diagrams to understand balanced and unbalanced forces.',
      'lessonStoryElementsDescription':
          'Study the essential parts of a story, including characters, setting, conflict, and resolution.',
      'lessonPlotStructureDescription':
          'Learn how events are arranged in a narrative from introduction to climax and conclusion.',
      'lessonQuizTitle': 'Lesson quiz',
      'lessonQuizSubtitleLinear':
          'Test your understanding of linear equations.',
      'lessonQuizSubtitleQuadratic':
          'Check your understanding of quadratic equations.',
      'lessonQuizSubtitlePhysics':
          'Check your understanding of force and motion.',
      'lessonQuizSubtitleNarrative':
          'Check your understanding of narrative structure.',
      'questionPrefix': 'Question ',
      'submitQuiz': 'Submit quiz',
      'quizLinearQuestionOne': 'What is x in 2x + 5 = 15?',
      'quizLinearQ1A': 'A) 5',
      'quizLinearQ1B': 'B) 10',
      'quizLinearQ1C': 'C) 20',
      'quizLinearQ1D': 'D) 15',
      'quizLinearQuestionTwo': 'Find y in 3y - 9 = 0.',
      'quizLinearQ2A': 'A) 1',
      'quizLinearQ2B': 'B) 2',
      'quizLinearQ2C': 'C) 3',
      'quizLinearQ2D': 'D) 0',
      'quizQuadraticQuestionOne':
          'Which formula is used to solve ax² + bx + c = 0?',
      'quizQuadraticQ1A': 'A) x = -b / 2a',
      'quizQuadraticQ1B': 'B) Quadratic formula',
      'quizQuadraticQ1C': 'C) Slope formula',
      'quizQuadraticQ1D': 'D) Area formula',
      'quizPhysicsQuestionOne': 'What unit is commonly used for force?',
      'quizPhysicsQ1A': 'A) Newton',
      'quizPhysicsQ1B': 'B) Meter',
      'quizPhysicsQ1C': 'C) Second',
      'quizPhysicsQ1D': 'D) Liter',
      'quizNarrativeQuestionOne': 'Which part usually introduces characters?',
      'quizNarrativeQ1A': 'A) Introduction',
      'quizNarrativeQ1B': 'B) Climax',
      'quizNarrativeQ1C': 'C) Resolution',
      'quizNarrativeQ1D': 'D) Footnote',
    },
    'km': {
      'appName': 'DGT',
      'welcomeBack': 'សូមស្វាគមន៍',
      'createAccount': 'បង្កើតគណនី',
      'loginSubtitle': 'ចូលប្រើដើម្បីបន្តទៅកាន់កន្លែងសិក្សារបស់អ្នក។',
      'registerSubtitle': 'បង្កើតប្រវត្តិរូបរបស់អ្នក ហើយចាប់ផ្តើមសិក្សា។',
      'email': 'អ៊ីមែល ឬលេខទូរស័ព្ទ',
      'password': 'ពាក្យសម្ងាត់',
      'username': 'ឈ្មោះអ្នកប្រើ',
      'fullName': 'ឈ្មោះពេញ',
      'grade': 'ថ្នាក់',
      'login': 'ចូលប្រើ',
      'register': 'ចុះឈ្មោះ',
      'goToRegister': 'បង្កើតគណនី',
      'goToLogin': 'មានគណនីរួចហើយ? ចូលប្រើ',
      'emailRequired': 'ត្រូវការអ៊ីមែល ឬលេខទូរស័ព្ទ',
      'emailInvalid': 'បញ្ចូលអ៊ីមែល ឬលេខទូរស័ព្ទឱ្យបានត្រឹមត្រូវ',
      'passwordRequired': 'ត្រូវការពាក្យសម្ងាត់',
      'passwordShort': 'ពាក្យសម្ងាត់ត្រូវមានយ៉ាងហោចណាស់ ៦ តួអក្សរ',
      'usernameRequired': 'ត្រូវការឈ្មោះអ្នកប្រើ',
      'fullNameRequired': 'ត្រូវការឈ្មោះពេញ',
      'gradeRequired': 'ត្រូវការថ្នាក់',
      'gradesLoadFailed': 'មិនអាចទាញយកថ្នាក់បានទេ',
      'authFailed': 'មានបញ្ហា។ សូមព្យាយាមម្តងទៀត។',
      'homeTitle': 'ទំព័រដើម',
      'homeMessage': 'អ្នកបានចូលប្រើជាមួយសេវា mock auth។',
      'homeSearchHint': 'ស្វែងរកមេរៀន ឬមុខវិជ្ជា...',
      'homeContinueLearning': 'បន្តការសិក្សា',
      'homePopularSubjects': 'មុខវិជ្ជាពេញនិយម',
      'homeRecommendedLessons': 'មេរៀនណែនាំ',
      'homeGreeting': 'អរុណសួស្តី',
      'homeStudentDefault': 'សិស្ស',
      'homeTodayPlan':
          'ថ្ងៃនេះអ្នកមានមេរៀន 3 ដែលបានរៀបចំ។ ចាប់ផ្តើមជាមួយរូបវិទ្យា ដើម្បីរក្សាគោលដៅប្រចាំសប្តាហ៍។',
      'homeContinueSubject': 'រូបវិទ្យា - ថ្នាក់ទី 11',
      'homeContinueTitle': 'ចលនាវិទ្យា',
      'homeContinueDescription':
          'ស្វែងយល់ពីចលនា ល្បឿន និងសំទុះ ជាមួយការអនុវត្តអន្តរកម្ម។',
      'homeProgress': 'វឌ្ឍនភាព',
      'homeSubjectMath': 'គណិតវិទ្យា',
      'homeSubjectChemistry': 'គីមីវិទ្យា',
      'homeSubjectBiology': 'ជីវវិទ្យា',
      'homeSubjectHistory': 'ប្រវត្តិវិទ្យា',
      'homeSubjectPhysics': 'រូបវិទ្យា',
      'homeSubjectKhmer': 'ភាសាខ្មែរ',
      'homeLessonAlgebra': 'មូលដ្ឋានពិជគណិត',
      'homeLessonAlgebraSubject': 'គណិតវិទ្យា - ថ្នាក់ទី 10',
      'homeLessonChemicalBonds': 'ចំណងគីមី',
      'homeLessonChemistrySubject': 'គីមីវិទ្យា - ថ្នាក់ទី 11',
      'homeLessonCellStructure': 'រចនាសម្ព័ន្ធកោសិកា',
      'homeLessonBiologySubject': 'ជីវវិទ្យា - ថ្នាក់ទី 9',
      'homeDuration18': '18 នាទី',
      'homeDuration24': '24 នាទី',
      'homeDuration16': '16 នាទី',
      'homeYourProgress': 'វឌ្ឍនភាពរបស់អ្នក',
      'homeTotalStudyTime': 'ពេលសិក្សាសរុប',
      'homeLessonsCompleted': 'មេរៀនបានបញ្ចប់',
      'homeDailyGoal': 'គោលដៅប្រចាំថ្ងៃ',
      'homeDailyGoalMessage': 'ជិតសម្រេចហើយ! បន្តទៅមុខទៀត។',
      'logout': 'ចាកចេញ',
      'language': 'ភាសា',
      'english': 'អង់គ្លេស',
      'khmer': 'ខ្មែរ',
      'toggleTheme': 'ប្ដូររូបរាង',
      'menuHome': 'ទំព័រដើម',
      'menuLearningCenter': 'ថ្នាក់រៀន',
      'menuBasicCourse': 'មូលដ្ឋានគ្រឹះ',
      'menuAiTutor': 'គ្រូ AI',
      'menuResource': 'ធនធាន',
      'basicCourseLoadFailed': 'មិនអាចទាញយកមុខវិជ្ជាមូលដ្ឋានបានទេ។',
      'basicCourseEmpty': 'មិនទាន់មានមុខវិជ្ជាមូលដ្ឋាននៅឡើយទេ។',
      'basicLessonsTitle': 'មេរៀនមូលដ្ឋាន',
      'basicLessonLoadFailed': 'មិនអាចទាញយកមេរៀនមូលដ្ឋានបានទេ។',
      'retry': 'ព្យាយាមម្តងទៀត',
      'comingSoon': 'មកដល់ឆាប់ៗនេះ',
      'learningCenterHero': 'រុករកវគ្គសិក្សា',
      'learningCenterSearchHint': 'ស្វែងរកជំពូក ឬប្រធានបទ...',
      'gradePrefix': 'ថ្នាក់ទី',
      'subjectMath': 'គណិតវិទ្យា',
      'subjectPhysics': 'រូបវិទ្យា',
      'subjectChemistry': 'គីមីវិទ្យា',
      'subjectBiology': 'ជីវវិទ្យា',
      'subjectLiterature': 'អក្សរសាស្ត្រ',
      'chapterAlgebra': 'ជំពូកទី ១៖ មូលដ្ឋានគ្រឹះពិជគណិត',
      'chapterForceMotion': 'ជំពូកទី ២៖ កម្លាំង និងចលនា',
      'chapterNarrative': 'ជំពូកទី ៣៖ រចនាសម្ព័ន្ធនិទានកថា',
      'lessonsTitle': 'មេរៀន',
      'lessonBundleAlgebraTitle': 'មូលដ្ឋានគ្រឹះពិជគណិត',
      'lessonBundleAlgebraDescription':
          'ស្ទាត់ជំនាញមូលដ្ឋានគ្រឹះនៃការគិតបែបពិជគណិត។ ជំពូកនេះគ្របដណ្ដប់លើសមីការលីនេអ៊ែរ រូបមន្តសមីការដឺក្រេទីពីរ និងប្រមាណវិធីពហុធា។',
      'lessonBundlePhysicsTitle': 'កម្លាំង និងចលនា',
      'lessonBundlePhysicsDescription':
          'ស្វែងយល់ពីរបៀបដែលកម្លាំងផ្លាស់ប្ដូរចលនា តាមរយៈឧទាហរណ៍ ជំនួយគំនូសតាង និងលំហាត់ណែនាំ។',
      'lessonBundleNarrativeTitle': 'រចនាសម្ព័ន្ធនិទានកថា',
      'lessonBundleNarrativeDescription':
          'រៀនពីរបៀបរៀបចំរឿងតាមតួអង្គ ទីកន្លែង ជម្លោះ ដំណើររឿង និងសេចក្ដីបញ្ចប់។',
      'lessonLinearEquations': '1.1 សមីការលីនេអ៊ែរ',
      'lessonQuadraticFormula': '1.2 រូបមន្តសមីការដឺក្រេទីពីរ',
      'lessonPolynomials': '1.3 ពហុធា',
      'lessonNewtonsLaws': '2.1 ច្បាប់ញូតុន',
      'lessonForceDiagrams': '2.2 គំនូសតាងកម្លាំង',
      'lessonMotionPractice': '2.3 លំហាត់ចលនា',
      'lessonStoryElements': '3.1 ធាតុនៃរឿង',
      'lessonPlotStructure': '3.2 រចនាសម្ព័ន្ធដំណើររឿង',
      'lessonWritingPractice': '3.3 លំហាត់សរសេរ',
      'lessonTypeVideo': 'វីដេអូ',
      'lessonTypeReading': 'ការអាន',
      'lessonTypeLocked': 'ចាក់សោ',
      'minutesShort': 'នាទី',
      'lessonDetailSubjectMath': 'គណិតវិទ្យា 101',
      'lessonDetailModuleOne': 'ម៉ូឌុល 1',
      'lessonLinearEquationsDescription':
          'រៀនពីរបៀបដោះស្រាយសមីការលីនេអ៊ែរជាមូលដ្ឋានដោយប្រើការបូក ដក គុណ និងចែក។ គំនិតជាមូលដ្ឋាននេះមានសារៈសំខាន់សម្រាប់ការយល់ដឹងពីពិជគណិត។',
      'lessonQuadraticFormulaDescription':
          'រៀនពេលណា និងរបៀបប្រើរូបមន្តសមីការដឺក្រេទីពីរ ដើម្បីដោះស្រាយសមីការដឺក្រេទីពីរយ៉ាងច្បាស់។',
      'lessonNewtonsLawsDescription':
          'ស្វែងយល់ពីច្បាប់ចលនារបស់ញូតុន និងទំនាក់ទំនងរវាងកម្លាំង ម៉ាស និងសំទុះ។',
      'lessonForceDiagramsDescription':
          'អនុវត្តការគូរ និងអានគំនូសតាងកម្លាំង ដើម្បីយល់ពីកម្លាំងសមតុល្យ និងមិនសមតុល្យ។',
      'lessonStoryElementsDescription':
          'សិក្សាផ្នែកសំខាន់ៗនៃរឿង រួមមានតួអង្គ ទីកន្លែង ជម្លោះ និងសេចក្ដីបញ្ចប់។',
      'lessonPlotStructureDescription':
          'រៀនពីរបៀបរៀបចំព្រឹត្តិការណ៍ក្នុងនិទានកថាចាប់ពីការណែនាំ ដល់ចំណុចកំពូល និងសេចក្ដីបញ្ចប់។',
      'lessonQuizTitle': 'កម្រងសំណួរមេរៀន',
      'lessonQuizSubtitleLinear': 'សាកល្បងចំណេះដឹងរបស់អ្នកលើសមីការលីនេអ៊ែរ។',
      'lessonQuizSubtitleQuadratic':
          'សាកល្បងចំណេះដឹងរបស់អ្នកលើសមីការដឺក្រេទីពីរ។',
      'lessonQuizSubtitlePhysics':
          'សាកល្បងចំណេះដឹងរបស់អ្នកអំពីកម្លាំង និងចលនា។',
      'lessonQuizSubtitleNarrative':
          'សាកល្បងចំណេះដឹងរបស់អ្នកអំពីរចនាសម្ព័ន្ធនិទានកថា។',
      'questionPrefix': 'សំណួរទី',
      'submitQuiz': 'បញ្ជូនកម្រងសំណួរ',
      'quizLinearQuestionOne': 'តើ x មានតម្លៃប៉ុន្មានក្នុង 2x + 5 = 15?',
      'quizLinearQ1A': 'ក) 5',
      'quizLinearQ1B': 'ខ) 10',
      'quizLinearQ1C': 'គ) 20',
      'quizLinearQ1D': 'ឃ) 15',
      'quizLinearQuestionTwo': 'រកតម្លៃ y ក្នុង 3y - 9 = 0។',
      'quizLinearQ2A': 'ក) 1',
      'quizLinearQ2B': 'ខ) 2',
      'quizLinearQ2C': 'គ) 3',
      'quizLinearQ2D': 'ឃ) 0',
      'quizQuadraticQuestionOne':
          'តើរូបមន្តណាត្រូវប្រើដើម្បីដោះស្រាយ ax² + bx + c = 0?',
      'quizQuadraticQ1A': 'ក) x = -b / 2a',
      'quizQuadraticQ1B': 'ខ) រូបមន្តសមីការដឺក្រេទីពីរ',
      'quizQuadraticQ1C': 'គ) រូបមន្តជម្រាល',
      'quizQuadraticQ1D': 'ឃ) រូបមន្តក្រឡាផ្ទៃ',
      'quizPhysicsQuestionOne': 'តើឯកតាណាដែលប្រើសម្រាប់កម្លាំង?',
      'quizPhysicsQ1A': 'ក) ញូតុន',
      'quizPhysicsQ1B': 'ខ) ម៉ែត្រ',
      'quizPhysicsQ1C': 'គ) វិនាទី',
      'quizPhysicsQ1D': 'ឃ) លីត្រ',
      'quizNarrativeQuestionOne': 'តើផ្នែកណាដែលជាទូទៅណែនាំតួអង្គ?',
      'quizNarrativeQ1A': 'ក) សេចក្ដីណែនាំ',
      'quizNarrativeQ1B': 'ខ) ចំណុចកំពូល',
      'quizNarrativeQ1C': 'គ) សេចក្ដីបញ្ចប់',
      'quizNarrativeQ1D': 'ឃ) កំណត់ចំណាំ',
    },
  };

  String text(String key) =>
      _values[locale.languageCode]?[key] ?? _values['en']?[key] ?? key;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

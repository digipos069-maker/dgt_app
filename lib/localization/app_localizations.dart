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
      'email': 'Email',
      'password': 'Password',
      'username': 'Username',
      'fullName': 'Full name',
      'grade': 'Grade',
      'login': 'Log in',
      'register': 'Register',
      'goToRegister': 'Create an account',
      'goToLogin': 'Already have an account? Log in',
      'emailRequired': 'Email is required',
      'emailInvalid': 'Enter a valid email address',
      'passwordRequired': 'Password is required',
      'passwordShort': 'Password must be at least 6 characters',
      'usernameRequired': 'Username is required',
      'fullNameRequired': 'Full name is required',
      'gradeRequired': 'Grade is required',
      'gradesLoadFailed': 'Failed to load grades',
      'authFailed': 'Something went wrong. Please try again.',
      'homeTitle': 'Home',
      'homeMessage': 'You are signed in with the mock auth service.',
      'logout': 'Log out',
      'language': 'Language',
      'english': 'English',
      'khmer': 'Khmer',
      'toggleTheme': 'Toggle theme',
      'menuHome': 'Home',
      'menuLearningCenter': 'Learning Center',
      'menuMyLearning': 'My Learning',
      'menuAiTutor': 'AI Tutor',
      'menuResource': 'Resource',
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
    },
    'km': {
      'appName': 'DGT',
      'welcomeBack': 'សូមស្វាគមន៍',
      'createAccount': 'បង្កើតគណនី',
      'loginSubtitle': 'ចូលប្រើដើម្បីបន្តទៅកាន់កន្លែងសិក្សារបស់អ្នក។',
      'registerSubtitle': 'បង្កើតប្រវត្តិរូបរបស់អ្នក ហើយចាប់ផ្តើមសិក្សា។',
      'email': 'អ៊ីមែល',
      'password': 'ពាក្យសម្ងាត់',
      'username': 'ឈ្មោះអ្នកប្រើ',
      'fullName': 'ឈ្មោះពេញ',
      'grade': 'ថ្នាក់',
      'login': 'ចូលប្រើ',
      'register': 'ចុះឈ្មោះ',
      'goToRegister': 'បង្កើតគណនី',
      'goToLogin': 'មានគណនីរួចហើយ? ចូលប្រើ',
      'emailRequired': 'ត្រូវការអ៊ីមែល',
      'emailInvalid': 'បញ្ចូលអាសយដ្ឋានអ៊ីមែលឱ្យបានត្រឹមត្រូវ',
      'passwordRequired': 'ត្រូវការពាក្យសម្ងាត់',
      'passwordShort': 'ពាក្យសម្ងាត់ត្រូវមានយ៉ាងហោចណាស់ ៦ តួអក្សរ',
      'usernameRequired': 'ត្រូវការឈ្មោះអ្នកប្រើ',
      'fullNameRequired': 'ត្រូវការឈ្មោះពេញ',
      'gradeRequired': 'ត្រូវការថ្នាក់',
      'gradesLoadFailed': 'មិនអាចទាញយកថ្នាក់បានទេ',
      'authFailed': 'មានបញ្ហា។ សូមព្យាយាមម្តងទៀត។',
      'homeTitle': 'ទំព័រដើម',
      'homeMessage': 'អ្នកបានចូលប្រើជាមួយសេវា mock auth។',
      'logout': 'ចាកចេញ',
      'language': 'ភាសា',
      'english': 'អង់គ្លេស',
      'khmer': 'ខ្មែរ',
      'toggleTheme': 'ប្ដូររូបរាង',
      'menuHome': 'ទំព័រដើម',
      'menuLearningCenter': 'មជ្ឈមណ្ឌលសិក្សា',
      'menuMyLearning': 'ការសិក្សារបស់ខ្ញុំ',
      'menuAiTutor': 'គ្រូ AI',
      'menuResource': 'ធនធាន',
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
    },
  };

  String text(String key) =>
      _values[locale.languageCode]?[key] ?? _values['en']![key]!;
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

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
      'gradeRequired': 'Grade is required',
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
      'gradeRequired': 'ត្រូវការថ្នាក់',
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

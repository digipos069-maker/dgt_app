import 'package:flutter/foundation.dart';

abstract final class ApiConstants {
  static const productionBaseUrl = 'https://api.digital-teachers.com';
  static const localBaseUrl = 'http://192.168.56.1:3002';

  /// Base URL configured automatically:
  /// - `flutter run` (debug mode): `http://192.168.56.1:3002`
  /// - `flutter build` (release / production mode): `https://api.digital-teachers.com`
  /// - Can also be overridden at build/run time via:
  ///   `--dart-define=API_BASE_URL=https://...`
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kDebugMode ? localBaseUrl : productionBaseUrl,
  );
  static const loginPath = '/api/auth/login';
  static const registerPath = '/api/auth/register';
  static const currentUserPath = '/api/auth/me';
  static const gradesPath = '/api/grades';
  static const lessonsPath = '/api/lessons';
  static const basicContentPath = '/api/basic-content';
  static const tutorialsPath = '/api/tutorials';
  static const tutorialBySlugPath = '$tutorialsPath/slug';
  static const quizSubmitPath = '/api/quiz/submit';
  static const dailyGoalPath = '/api/daily-goal';
  static const fcmTokenPath = '/api/fcm-token';
  static const videoCompletionPath = '/api/video/complete';
  static const examsTypesPath = '/api/exams/types';
  static const examsDocumentsPath = '/api/exams/documents';
  static const mobileResourceByYearPath = '/api/m/resource-by-year';
  static const mobileResourcesPath = '/api/m/resources';
  static const mobileResourceListPath = '/api/m/resource-list';
  static const uploadPayslipPath = '/api/payment/upload-payslip';
  static const bankTransferPaymentPath = '/api/payment/bank-transfer';
  static const upgradeSubscriptionPath = '/api/upgrade-subscription';
}

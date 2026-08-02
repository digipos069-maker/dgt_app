abstract final class ApiConstants {
  static const baseUrl = 'http://192.168.56.1:3002';
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
}

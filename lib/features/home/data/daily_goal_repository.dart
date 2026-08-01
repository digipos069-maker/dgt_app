import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_controller.dart';
import '../domain/models/daily_goal_model.dart';
import 'daily_goal_api_service.dart';

final dailyGoalRepositoryProvider = Provider<DailyGoalRepository>((ref) {
  return DailyGoalRepository(DailyGoalApiService());
});

class DailyGoalRepository {
  DailyGoalRepository(this._apiService);

  final DailyGoalApiService _apiService;

  Future<DailyGoalModel> fetchDailyGoal(String token) {
    return _apiService.fetchDailyGoal(token);
  }

  Future<void> updateDailyGoal(String token, {required int targetVideos, required int targetQuizzes}) {
    return _apiService.updateDailyGoal(token, targetVideos: targetVideos, targetQuizzes: targetQuizzes);
  }

  Future<void> updateFcmToken(String token, String fcmToken) {
    return _apiService.updateFcmToken(token, fcmToken);
  }

  Future<void> completeVideo(String token, int videoId) {
    return _apiService.completeVideo(token, videoId);
  }
}

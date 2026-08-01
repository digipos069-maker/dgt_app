import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_controller.dart';
import '../../../core/services/notification_service.dart';
import '../data/daily_goal_repository.dart';
import '../domain/models/daily_goal_model.dart';

final dailyGoalControllerProvider = AsyncNotifierProvider<DailyGoalController, DailyGoalModel?>(DailyGoalController.new);

class DailyGoalController extends AsyncNotifier<DailyGoalModel?> {
  @override
  Future<DailyGoalModel?> build() async {
    final user = ref.watch(authControllerProvider).value;
    if (user?.token == null) return null;

    // Sync FCM Token now that user is loaded
    ref.read(notificationServiceProvider).syncToken();

    try {
      final repository = ref.read(dailyGoalRepositoryProvider);
      return await repository.fetchDailyGoal(user!.token!);
    } catch (e) {
      developer.log('Error fetching daily goal', error: e);
      return const DailyGoalModel(
        targetVideos: 3,
        targetQuizzes: 15,
        completedVideos: 0,
        completedQuizzes: 0,
      );
    }
  }

  Future<void> updateGoal({required int targetVideos, required int targetQuizzes}) async {
    final user = ref.read(authControllerProvider).value;
    if (user?.token == null) return;

    final repository = ref.read(dailyGoalRepositoryProvider);
    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      await repository.updateDailyGoal(user!.token!, targetVideos: targetVideos, targetQuizzes: targetQuizzes);
      return await repository.fetchDailyGoal(user.token!);
    });
  }
}

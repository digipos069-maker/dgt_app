import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/home/data/daily_goal_repository.dart';
import 'local_storage_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.read(sharedPreferencesProvider), ref);
});

class NotificationService {
  NotificationService(this._prefs, this._ref);

  final SharedPreferences _prefs;
  final Ref _ref;
  static const _fcmTokenKey = 'fcm_token';

  Future<void> initialize() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Request permission (Required for iOS, Android 13+)
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');
        
        // Get the token
        final token = await messaging.getToken();
        if (token != null) {
          await _saveAndSyncToken(token);
        }

        // Listen for token refreshes
        messaging.onTokenRefresh.listen(_saveAndSyncToken);
      } else {
        print('User declined or has not accepted permission');
      }
    } on Object catch (e, st) {
      print('Failed to initialize FCM: $e');
    }
  }

  Future<void> _saveAndSyncToken(String token) async {
    final cachedToken = _prefs.getString(_fcmTokenKey);
    if (cachedToken != token) {
      print('New FCM Token generated: $token');
      await _prefs.setString(_fcmTokenKey, token);
    }
    
    await syncToken();
  }

  Future<void> syncToken() async {
    final token = _prefs.getString(_fcmTokenKey);
    final user = _ref.read(authControllerProvider).value;
    
    print('Attempting to sync FCM token. Local token exists: ${token != null}, User exists: ${user?.token != null}');
    
    if (token != null && user?.token != null) {
      try {
        print('Sending FCM token to backend...');
        await _ref.read(dailyGoalRepositoryProvider).updateFcmToken(user!.token!, token);
        print('FCM Token synced to API successfully');
      } catch (e) {
        print('Failed to sync FCM token: $e');
      }
    }
  }

  String? get currentToken => _prefs.getString(_fcmTokenKey);
}

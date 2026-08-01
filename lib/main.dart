import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'dart:developer' as developer;

import 'app/app.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();

  try {
    await Firebase.initializeApp();
  } on Object catch (e) {
    print('Firebase initialization failed (Missing config?): $e');
  }

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
  );
  
  // Initialize Notification Service for FCM
  await container.read(notificationServiceProvider).initialize();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const DgtApp(),
    ),
  );
}

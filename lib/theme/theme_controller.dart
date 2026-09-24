import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/storage_keys.dart';
import '../core/services/local_storage_service.dart';

final themeControllerProvider = NotifierProvider<ThemeController, ThemeMode>(
  ThemeController.new,
);

class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final storage = ref.watch(localStorageServiceProvider);
    final storedTheme = storage.readString(StorageKeys.themeMode);
    return switch (storedTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.light,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final selectedMode = mode == ThemeMode.dark ? ThemeMode.dark : ThemeMode.light;
    state = selectedMode;
    await ref
        .read(localStorageServiceProvider)
        .writeString(StorageKeys.themeMode, selectedMode.name);
  }

  Future<void> toggleTheme() async {
    await setThemeMode(
      state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}

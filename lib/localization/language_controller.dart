import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/storage_keys.dart';
import '../core/services/local_storage_service.dart';

final languageControllerProvider = NotifierProvider<LanguageController, Locale>(
  LanguageController.new,
);

class LanguageController extends Notifier<Locale> {
  @override
  Locale build() {
    final storage = ref.watch(localStorageServiceProvider);
    return Locale(storage.readString(StorageKeys.languageCode) ?? 'km');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await ref
        .read(localStorageServiceProvider)
        .writeString(StorageKeys.languageCode, locale.languageCode);
  }
}

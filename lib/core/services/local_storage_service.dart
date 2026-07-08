import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService(ref.watch(sharedPreferencesProvider));
});

class LocalStorageService {
  const LocalStorageService(this._preferences);

  final SharedPreferences _preferences;

  String? readString(String key) => _preferences.getString(key);

  Future<void> writeString(String key, String value) async {
    await _preferences.setString(key, value);
  }
}

import 'package:dgt_app/app/app.dart';
import 'package:dgt_app/core/services/local_storage_service.dart';
import 'package:dgt_app/features/auth/data/auth_session_storage.dart';
import 'package:dgt_app/features/auth/domain/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows login screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          authSessionStorageProvider.overrideWithValue(
            const _EmptyAuthSessionStorage(),
          ),
        ],
        child: const DgtApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('សូមស្វាគមន៍'), findsOneWidget);
    expect(find.text('អ៊ីមែល ឬលេខទូរស័ព្ទ'), findsOneWidget);
    expect(find.text('ពាក្យសម្ងាត់'), findsOneWidget);
  });
}

class _EmptyAuthSessionStorage implements AuthSessionStorage {
  const _EmptyAuthSessionStorage();

  @override
  Future<void> clearSession() async {}

  @override
  Future<UserModel?> readSession() async => null;

  @override
  Future<void> saveSession(UserModel user) async {}
}

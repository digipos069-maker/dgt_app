import 'package:flutter_riverpod/flutter_riverpod.dart';
class TestRequest {}
class TestNotifier extends AsyncNotifier<int> {
  TestNotifier({required this.arg});
  final TestRequest arg;
  @override
  Future<int> build() async => 1;
}
final testProvider = AsyncNotifierProvider.autoDispose.family<TestNotifier, int, TestRequest>(
  (arg) => TestNotifier(arg: arg),
);

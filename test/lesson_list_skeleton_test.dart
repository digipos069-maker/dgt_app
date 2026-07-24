import 'package:dgt_app/features/home/presentation/widgets/lesson_list_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('lesson list skeleton fits phone and tablet widths', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final size in const [Size(320, 760), Size(800, 1000)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LessonListSkeleton())),
      );
      await tester.pump();

      expect(find.byType(LessonListSkeleton), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}

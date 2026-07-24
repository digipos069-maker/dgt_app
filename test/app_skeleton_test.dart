import 'package:dgt_app/core/widgets/app_skeleton.dart';
import 'package:dgt_app/features/home/presentation/widgets/lesson_detail_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders reusable skeleton boxes without semantics noise', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppSkeletonShimmer(
          child: Column(
            children: [
              AppSkeletonBox(width: 120, height: 20),
              AppSkeletonBox.circle(size: 40),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(AppSkeletonBox), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tutorial detail skeleton fits narrow and wide layouts', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final size in const [Size(320, 760), Size(1024, 900)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LessonDetailSkeleton())),
      );
      await tester.pump();

      expect(find.byType(LessonDetailSkeleton), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}

import 'package:dgt_app/features/auth/application/grade_controller.dart';
import 'package:dgt_app/features/auth/domain/models/grade_model.dart';
import 'package:dgt_app/features/auth/presentation/widgets/home_subject_grid.dart';
import 'package:dgt_app/features/home/presentation/pages/learning_center_page.dart';
import 'package:dgt_app/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  for (final entry in {
    'Math': 1,
    'Chemistry': 3,
    'Biology': 4,
    'Physics': 2,
  }.entries) {
    testWidgets(
      '${entry.key} opens its Grade 12 lessons using the API grade ID',
      (tester) async {
        Uri? destination;
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const Scaffold(
                body: SingleChildScrollView(child: HomeSubjectGrid()),
              ),
            ),
            GoRoute(
              path: LearningCenterPage.routePath,
              name: LearningCenterPage.routeName,
              builder: (_, state) {
                destination = state.uri;
                return const Scaffold(body: Text('Lessons destination'));
              },
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              gradesProvider.overrideWith(
                (ref) async => const [
                  GradeModel(id: 5, number: 11, name: 'Grade 11'),
                  GradeModel(id: 99, number: 12, name: 'Grade 12'),
                ],
              ),
            ],
            child: MaterialApp.router(
              routerConfig: router,
              locale: const Locale('en'),
              localizationsDelegates: const [AppLocalizations.delegate],
            ),
          ),
        );
        await tester.pumpAndSettle();
        final label = AppLocalizations(
          const Locale('en'),
        ).text('homeSubject${entry.key}');
        await tester.ensureVisible(find.text(label));
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(destination?.queryParameters, {
          'gradeId': '99',
          'gradeNumber': '12',
          'subjectId': entry.value.toString(),
        });
        expect(find.text('Lessons destination'), findsOneWidget);
        router.pop();
        await tester.pumpAndSettle();
        expect(find.byType(HomeSubjectGrid), findsOneWidget);
      },
    );
  }
}

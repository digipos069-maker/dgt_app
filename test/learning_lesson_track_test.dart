import 'package:dgt_app/features/home/domain/models/learning_lesson_model.dart';
import 'package:dgt_app/features/home/domain/models/lesson_track.dart';
import 'package:dgt_app/features/home/presentation/widgets/learning_center_body.dart';
import 'package:dgt_app/features/home/presentation/widgets/lesson_track_badge.dart';
import 'package:dgt_app/features/home/presentation/widgets/lesson_track_filter_strip.dart';
import 'package:dgt_app/localization/app_localizations.dart';
import 'package:dgt_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTestApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light(const Locale('en')),
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('LearningLessonModel track_type parsing', () {
    test('parses track_type integer 1 (Science) and 2 (Social)', () {
      final jsonScience = {
        'id': 'lesson-1',
        'title': 'Advanced Physics',
        'description': 'Physics for science track',
        'thumbnail': '',
        'subjectId': 2,
        'gradeId': 12,
        'durationMinutes': 45,
        'rating': 4.9,
        'learnerCount': 120,
        'isLocked': false,
        'track_type': 1,
      };

      final lessonScience = LearningLessonModel.fromJson(jsonScience);
      expect(lessonScience.trackType, 1);
      expect(lessonScience.track, LessonTrack.science);
      expect(lessonScience.track?.labelKm, 'ថ្នាក់វិទ្យាសាស្រ្ដ');

      final jsonSocial = Map<String, dynamic>.from(jsonScience)
        ..['track_type'] = 2;
      final lessonSocial = LearningLessonModel.fromJson(jsonSocial);
      expect(lessonSocial.trackType, 2);
      expect(lessonSocial.track, LessonTrack.social);
      expect(lessonSocial.track?.labelKm, 'ថ្នាក់សង្គម');

      final jsonNull = Map<String, dynamic>.from(jsonScience)
        ..remove('track_type');
      final lessonNull = LearningLessonModel.fromJson(jsonNull);
      expect(lessonNull.trackType, isNull);
      expect(lessonNull.track, isNull);

      final jsonCamel = Map<String, dynamic>.from(jsonScience)
        ..remove('track_type')
        ..['trackType'] = '2';
      final lessonCamel = LearningLessonModel.fromJson(jsonCamel);
      expect(lessonCamel.trackType, 2);
    });
  });

  group('LessonTrackBadge on Learning Center', () {
    testWidgets('renders Science badge with biotech icon for track 1', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const LessonTrackBadge(trackType: 1)),
      );
      await tester.pumpAndSettle();

      expect(find.text('ថ្នាក់វិទ្យាសាស្រ្ដ'), findsOneWidget);
      expect(find.byIcon(Icons.biotech_outlined), findsOneWidget);
    });

    testWidgets('renders Social badge with public icon for track 2', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const LessonTrackBadge(trackType: 2)),
      );
      await tester.pumpAndSettle();

      expect(find.text('ថ្នាក់សង្គម'), findsOneWidget);
      expect(find.byIcon(Icons.public_outlined), findsOneWidget);
    });

    testWidgets('renders nothing when trackType is null', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const LessonTrackBadge(trackType: null)),
      );
      await tester.pumpAndSettle();

      expect(find.text('ថ្នាក់វិទ្យាសាស្រ្ដ'), findsNothing);
      expect(find.text('ថ្នាក់សង្គម'), findsNothing);
    });
  });

  group('LessonTrackFilterStrip', () {
    testWidgets('filters by track on tap', (tester) async {
      int? selected;

      await tester.pumpWidget(
        _buildTestApp(
          StatefulBuilder(
            builder: (context, setState) {
              return LessonTrackFilterStrip(
                selectedTrack: selected,
                availableTracks: const {1, 2},
                onTrackSelected: (val) {
                  setState(() => selected = val);
                },
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ទាំងអស់'), findsOneWidget);
      expect(find.text('ថ្នាក់វិទ្យាសាស្រ្ដ'), findsOneWidget);
      expect(find.text('ថ្នាក់សង្គម'), findsOneWidget);

      await tester.tap(find.text('ថ្នាក់វិទ្យាសាស្រ្ដ'));
      await tester.pumpAndSettle();
      expect(selected, 1);

      await tester.tap(find.text('ថ្នាក់សង្គម'));
      await tester.pumpAndSettle();
      expect(selected, 2);

      await tester.tap(find.text('ទាំងអស់'));
      await tester.pumpAndSettle();
      expect(selected, isNull);
    });
  });

  group('LearningCenterBody with track badges and filtering', () {
    testWidgets('renders track badges on cards and filters correctly', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const lessons = [
        LearningLessonModel(
          id: 'l1',
          title: 'Science Lesson A',
          description: '',
          thumbnail: '',
          subjectId: 1,
          gradeId: 12,
          durationMinutes: 30,
          rating: 5.0,
          learnerCount: 20,
          isLocked: false,
          trackType: 1,
        ),
        LearningLessonModel(
          id: 'l2',
          title: 'Social Lesson B',
          description: '',
          thumbnail: '',
          subjectId: 1,
          gradeId: 12,
          durationMinutes: 25,
          rating: 4.8,
          learnerCount: 15,
          isLocked: false,
          trackType: 2,
        ),
        LearningLessonModel(
          id: 'l3',
          title: 'General Lesson C',
          description: '',
          thumbnail: '',
          subjectId: 1,
          gradeId: 12,
          durationMinutes: 20,
          rating: 4.5,
          learnerCount: 10,
          isLocked: false,
          trackType: null,
        ),
      ];

      await tester.pumpWidget(
        _buildTestApp(
          LearningCenterBody(
            gradeId: 12,
            gradeNumber: 12,
            initialSubjectId: 1,
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
    });
  });
}

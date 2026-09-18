import 'package:dgt_app/features/home/domain/models/resource_document_model.dart';
import 'package:dgt_app/features/home/presentation/widgets/resource_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dgt_app/localization/app_localizations.dart';

Widget _buildTestableWidget(ResourceDocumentModel document) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(
      body: SingleChildScrollView(
        child: ResourcePdfViewer(document: document),
      ),
    ),
  );
}

void main() {
  group('ResourcePdfViewer Widget Tests', () {
    testWidgets('renders error view when document sourceUrl is empty', (tester) async {
      const document = ResourceDocumentModel(
        id: '1',
        year: 2024,
        title: 'Physics Exam',
        description: 'Past exam paper',
        subjectId: '10',
        subjectName: 'Physics',
        type: ResourceDocumentType.pdf,
        sourceUrl: '',
        pageCount: 5,
        durationLabel: '',
      );

      await tester.pumpWidget(_buildTestableWidget(document));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.picture_as_pdf_outlined), findsWidgets);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('renders toolbar with zoom controls and page controls', (tester) async {
      const document = ResourceDocumentModel(
        id: '2',
        year: 2024,
        title: 'Math Exam',
        description: 'Past math exam paper',
        subjectId: '11',
        subjectName: 'Math',
        type: ResourceDocumentType.pdf,
        sourceUrl: 'https://example.com/mock.pdf',
        pageCount: 10,
        durationLabel: '',
      );

      await tester.pumpWidget(_buildTestableWidget(document));
      await tester.pump();

      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.fit_screen_outlined), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('renders retry button and triggers reload on tap when error occurs', (tester) async {
      const document = ResourceDocumentModel(
        id: '3',
        year: 2024,
        title: 'Draft Resource',
        description: 'Draft description',
        subjectId: '12',
        subjectName: 'History',
        type: ResourceDocumentType.pdf,
        sourceUrl: '',
        pageCount: 1,
        durationLabel: '',
      );

      await tester.pumpWidget(_buildTestableWidget(document));
      await tester.pumpAndSettle();

      final retryButton = find.byType(FilledButton);
      expect(retryButton, findsOneWidget);
      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      expect(find.byType(FilledButton), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dgt_app/features/home/application/resource_controller.dart';
import 'package:dgt_app/features/home/domain/models/exam_resource_model.dart';
import 'package:dgt_app/features/home/domain/models/resource_document_model.dart';
import 'package:dgt_app/features/home/presentation/widgets/resource_list_by_years_body.dart';
import 'package:dgt_app/localization/app_localizations.dart';

void main() {
  testWidgets('ResourceListByYearsBody renders documents and uses #032EA1 styling for active chip', (tester) async {
    final bundle = ResourceDocumentBundle(
      exam: const ExamResourceModel(
        id: '1',
        examName: 'BacII',
        icon: 'certificate',
        shortDescription: 'BacII Exam',
      ),
      year: 2023,
      subjects: const [
        ResourceSubjectModel(id: '1', name: 'Mathematics'),
        ResourceSubjectModel(id: '2', name: 'Physics'),
      ],
      documents: const [
        ResourceDocumentModel(
          id: '101',
          year: 2023,
          title: 'Mathematics Exam 2023',
          description: 'Official test paper',
          subjectId: '1',
          subjectName: 'Mathematics',
          type: ResourceDocumentType.pdf,
          sourceUrl: 'https://example.com/math.pdf',
          pageCount: 4,
          durationLabel: '',
        ),
      ],
      meta: const ResourcePaginationMeta(total: 1, page: 1, limit: 10, totalPages: 1),
    );

    final request = const ResourcesByYearRequest(
      examId: '1',
      year: 2023,
      languageCode: 'en',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resourcesByYearProvider(request).overrideWith(
            () => _FakeResourcesNotifier(bundle),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultMaterialLocalizations.delegate,
          ],
          home: Scaffold(
            body: ResourceListByYearsBody(examId: '1', year: 2023),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify header title and document
    expect(find.textContaining('BacII'), findsWidgets);
    expect(find.textContaining('Mathematics Exam 2023'), findsOneWidget);

    // Verify search text field exists
    expect(find.byType(TextField), findsOneWidget);

    // Verify filter chips exist
    final chips = tester.widgetList<FilterChip>(find.byType(FilterChip)).toList();
    expect(chips.length, 3); // All Subjects + Math + Physics

    // Active chip must use #032EA1 (Color(0xFF032EA1))
    final allSubjectsChip = chips.first;
    expect(allSubjectsChip.selected, isTrue);
    expect(allSubjectsChip.selectedColor, const Color(0xFF032EA1));
  });
}

class _FakeResourcesNotifier extends ResourcesByYearNotifier {
  _FakeResourcesNotifier(this._initialBundle) : super(const ResourcesByYearRequest(examId: '1', year: 2023, languageCode: 'en'));

  final ResourceDocumentBundle _initialBundle;

  @override
  Future<ResourceDocumentBundle> build() async {
    return _initialBundle;
  }
}

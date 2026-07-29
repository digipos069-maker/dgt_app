import 'package:dgt_app/features/home/data/resource_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const repository = ResourceRepository();

  test('returns localized exam resources with access states', () async {
    final english = await repository.fetchResources(languageCode: 'en');
    final khmer = await repository.fetchResources(languageCode: 'km');

    expect(english, hasLength(5));
    expect(khmer, hasLength(5));
    expect(khmer.first.examName, 'ប្រឡងសិស្សពូកែ');
    expect(english.first.icon, 'trophy');
    expect(english.any((resource) => resource.isLocked), isTrue);
    expect(english.any((resource) => !resource.isLocked), isTrue);
  });

  test('returns years for the selected exam resource', () async {
    final bundle = await repository.fetchResourceYears(
      examId: 'bac-ii',
      languageCode: 'en',
    );

    expect(bundle.exam.id, 'bac-ii');
    expect(bundle.years, isNotEmpty);
    expect(bundle.years.first.year, 2025);
    expect(bundle.years.first.resourceCount, greaterThan(0));
  });

  test('returns localized documents and subjects for a year', () async {
    final bundle = await repository.fetchResourcesByYear(
      examId: 'bac-ii',
      year: 2025,
      languageCode: 'en',
    );

    expect(bundle.exam.id, 'bac-ii');
    expect(bundle.year, 2025);
    expect(bundle.subjects, isNotEmpty);
    expect(bundle.documents, isNotEmpty);
    expect(
      bundle.documents.every(
        (document) =>
            bundle.subjects.any((subject) => subject.id == document.subjectId),
      ),
      isTrue,
    );
  });
}

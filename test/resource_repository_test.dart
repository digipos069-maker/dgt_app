import 'package:dgt_app/features/home/data/resource_api_service.dart';
import 'package:dgt_app/features/home/data/resource_repository.dart';
import 'package:dgt_app/features/home/domain/models/exam_resource_model.dart';
import 'package:flutter_test/flutter_test.dart';

class MockResourceApiService extends ResourceApiService {
  @override
  Future<List<ExamResourceModel>> fetchExamTypes({required String token}) async {
    return [
      const ExamResourceModel(
        id: 'bac-ii',
        examName: 'BAC II Exam',
        icon: 'certificate',
        shortDescription: 'Study past BAC II questions',
      ),
      const ExamResourceModel(
        id: 'outstanding-student',
        examName: 'ប្រឡងសិស្សពូកែ',
        icon: 'trophy',
        shortDescription: 'ហ្វឹកហាត់សំណួរកម្រិតខ្ពស់',
      ),
    ];
  }
}

void main() {
  final apiService = MockResourceApiService();
  final repository = ResourceRepository(apiService: apiService);

  test('returns exam resources from API plus static items', () async {
    final english = await repository.fetchResources(token: 'dummy', languageCode: 'en');
    final khmer = await repository.fetchResources(token: 'dummy', languageCode: 'km');

    expect(english, hasLength(4)); // 2 from API + 2 static
    expect(khmer, hasLength(4));
    expect(khmer.last.examName, 'ឯកសារសិក្សា');
    expect(english.first.icon, 'certificate');
  });

  test('returns years for the selected exam resource', () async {
    final bundle = await repository.fetchResourceYears(
      token: 'dummy',
      examId: 'bac-ii',
      languageCode: 'en',
    );

    expect(bundle.exam.id, 'bac-ii');
    expect(bundle.years, hasLength(16));
    expect(bundle.years.first.year, 2025);
    expect(bundle.years.last.year, 2010);
    expect(bundle.years.first.resourceCount, greaterThan(0));
  });

  test('returns localized documents and subjects for a year', () async {
    final bundle = await repository.fetchResourcesByYear(
      token: 'dummy',
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

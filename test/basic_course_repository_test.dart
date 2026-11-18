import 'package:dgt_app/features/home/data/basic_course_api_service.dart';
import 'package:dgt_app/features/home/data/basic_course_repository.dart';
import 'package:dgt_app/features/home/domain/models/basic_course_model.dart';
import 'package:dgt_app/features/home/domain/models/basic_lesson_model.dart';
import 'package:flutter_test/flutter_test.dart';

class MockBasicCourseApiService extends BasicCourseApiService {
  @override
  Future<Map<String, dynamic>> fetchBasicContentRaw({
    required String token,
    required String subjectId,
    int page = 1,
    int limit = 10,
    int? offset,
  }) async {
    return {
      'data': [
        {
          'id': 1,
          'title': 'Numbers and operations',
          'slug': 'numbers-operations',
          'subject': {'nameEn': 'Mathematics', 'nameKm': 'គណិតវិទ្យា'},
        }
      ]
    };
  }

  @override
  Future<Map<String, dynamic>> fetchBasicContentDetail({
    required String token,
    required String slug,
  }) async {
    return {
      'data': {
        'id': 1,
        'title': 'Numbers and operations',
        'slug': slug,
      }
    };
  }
}

void main() {
  final apiService = MockBasicCourseApiService();
  final repository = BasicCourseRepository(apiService: apiService);

  test('returns basic courses and lesson details from API data', () async {
    final courses = await repository.fetchBasicCourses(languageCode: 'en');
    final bundle = await repository.fetchBasicLessons(
      token: 'dummy-token',
      courseId: 'mathematics',
      languageCode: 'en',
    );
    final detail = await repository.fetchBasicLessonDetail(
      token: 'dummy-token',
      courseId: 'mathematics',
      lessonId: 'numbers-operations',
      languageCode: 'en',
    );

    expect(courses, hasLength(4)); // Still uses hardcoded mock data for courses
    expect(bundle.course.id, 'mathematics');
    expect(bundle.lessons, hasLength(1));
    expect(detail.lessonId, 'numbers-operations');
    expect(detail.questions, isNotEmpty);
    expect(detail.questions.first.options, hasLength(3)); // Uses hardcoded mock for quizzes
  });
}

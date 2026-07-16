import 'package:dgt_app/features/home/data/basic_course_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const repository = BasicCourseRepository();

  test('returns basic courses and lesson details from mock API data', () async {
    final courses = await repository.fetchBasicCourses(languageCode: 'en');
    final lessons = await repository.fetchBasicLessons(
      courseId: 'mathematics',
      languageCode: 'en',
    );
    final detail = await repository.fetchBasicLessonDetail(
      courseId: 'mathematics',
      lessonId: 'numbers-operations',
      languageCode: 'en',
    );

    expect(courses, hasLength(4));
    expect(lessons.course.id, 'mathematics');
    expect(lessons.lessons, hasLength(3));
    expect(detail.lessonId, 'numbers-operations');
    expect(detail.questions, isNotEmpty);
    expect(detail.questions.first.options, hasLength(4));
  });
}

import 'package:dgt_app/features/auth/application/grade_controller.dart';
import 'package:dgt_app/features/auth/data/grade_api_service.dart';
import 'package:dgt_app/features/auth/data/grade_repository.dart';
import 'package:dgt_app/features/home/application/learning_lesson_controller.dart';
import 'package:dgt_app/features/home/data/learning_lesson_api_service.dart';
import 'package:dgt_app/features/home/data/learning_lesson_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('grades remain cached for the app session', () async {
    var requestCount = 0;
    final repository = GradeRepository(
      GradeApiService(
        client: MockClient((_) async {
          requestCount++;
          return http.Response('[{"id":12,"number":12}]', 200);
        }),
      ),
    );
    final container = ProviderContainer(
      overrides: [gradeRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final first = await container.read(gradesProvider.future);
    final second = await container.read(gradesProvider.future);

    expect(first.single.number, 12);
    expect(second.single.number, 12);
    expect(requestCount, 1);
  });

  test('lesson query remains cached after its listener closes', () async {
    var requestCount = 0;
    final repository = LearningLessonRepository(
      LearningLessonApiService(
        client: MockClient((_) async {
          requestCount++;
          return http.Response('[{"id":1,"title":"Algebra"}]', 200);
        }),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        learningLessonRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    const request = LearningLessonsRequest(gradeId: 12, subjectId: 1);
    final provider = learningLessonsProvider(request);

    final firstListener = container.listen(provider, (_, _) {});
    await container.read(provider.future);
    firstListener.close();
    await Future<void>.delayed(Duration.zero);

    final secondListener = container.listen(provider, (_, _) {});
    await container.read(provider.future);
    secondListener.close();

    expect(requestCount, 1);
  });
}

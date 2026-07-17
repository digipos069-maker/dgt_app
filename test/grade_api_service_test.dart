import 'package:dgt_app/features/auth/data/grade_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('requests grades in descending order', () async {
    late Uri requestedUri;
    final service = GradeApiService(
      client: MockClient((request) async {
        requestedUri = request.url;
        return http.Response('[{"id":12,"number":12}]', 200);
      }),
    );

    final grades = await service.fetchGrades();

    expect(requestedUri.path, '/api/grades');
    expect(requestedUri.queryParameters['order'], 'desc');
    expect(grades, hasLength(1));
  });
}

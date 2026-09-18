import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:dgt_app/core/constants/api_constants.dart';
import 'package:dgt_app/features/home/data/resource_api_service.dart';
import 'package:dgt_app/features/home/data/resource_repository.dart';
import 'package:dgt_app/features/home/domain/models/resource_document_model.dart';
import 'package:dgt_app/features/home/domain/models/resource_year_model.dart';

void main() {
  group('Query Parameter Sanitization', () {
    test('strips null, empty, and out-of-bounds parameters strictly for NestJS', () {
      final sanitized = ResourceApiService.sanitizeQueryParams(
        year: null,
        examTypeId: null,
        subjectId: null,
        search: null,
        page: null,
        limit: null,
      );
      expect(sanitized.isEmpty, isTrue);

      final outOfBounds = ResourceApiService.sanitizeQueryParams(
        year: 1800, // < 1900
        examTypeId: -1,
        subjectId: 0,
        search: '   ',
        page: 0,
        limit: 105, // > 100
      );
      expect(outOfBounds.isEmpty, isTrue);

      final valid = ResourceApiService.sanitizeQueryParams(
        year: 2023,
        examTypeId: 2,
        subjectId: 5,
        search: 'Physics',
        page: 1,
        limit: 20,
      );
      expect(valid['year'], '2023');
      expect(valid['examTypeId'], '2');
      expect(valid['subjectId'], '5');
      expect(valid['search'], 'Physics');
      expect(valid['page'], '1');
      expect(valid['limit'], '20');
      expect(valid.containsKey('unknownParam'), isFalse);
    });
  });

  group('Endpoint 1: /api/m/resource-by-year', () {
    test('fetches resource counts by specific year', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, ApiConstants.mobileResourceByYearPath);
        expect(request.url.queryParameters['year'], '2023');

        return http.Response(
          jsonEncode({
            'year': 2023,
            'total': 25,
            'examTypes': [
              {
                'id': 1,
                'name': 'BacII',
                'description': 'National High School Exam',
                'useTrack': true,
                'total': 15,
                'totalDocuments': 15,
              },
              {
                'id': 2,
                'name': 'Grade 9',
                'description': 'Junior High Exam',
                'useTrack': false,
                'total': 10,
                'totalDocuments': 10,
              },
            ],
            'data': [],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ResourceApiService(client: mockClient);
      final result = await service.fetchResourceByYear(year: 2023);

      expect(result['year'], 2023);
      expect(result['total'], 25);
      final examTypes = (result['examTypes'] as List).map((e) => ExamTypeCountModel.fromJson(e as Map<String, dynamic>)).toList();
      expect(examTypes.length, 2);
      expect(examTypes.first.name, 'BacII');
      expect(examTypes.first.totalDocuments, 15);
      expect(examTypes.first.useTrack, isTrue);
    });

    test('fetches aggregated resource counts when year is omitted', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, ApiConstants.mobileResourceByYearPath);
        expect(request.url.queryParameters.containsKey('year'), isFalse);

        return http.Response(
          jsonEncode({
            'total': 50,
            'years': [
              {
                'year': 2024,
                'total': 30,
                'examTypes': [
                  {'id': 1, 'name': 'BacII', 'total': 30, 'totalDocuments': 30},
                ],
              },
              {
                'year': 2023,
                'total': 20,
                'examTypes': [
                  {'id': 1, 'name': 'BacII', 'total': 20, 'totalDocuments': 20},
                ],
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ResourceApiService(client: mockClient);
      final result = await service.fetchResourceByYear();

      expect(result['total'], 50);
      final years = result['years'] as List;
      expect(years.length, 2);
      expect(years[0]['year'], 2024);
      expect(years[1]['year'], 2023);
    });
  });

  group('Endpoint 2: /api/m/resources', () {
    test('fetches paginated mobile resources and maps models defensively', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, ApiConstants.mobileResourcesPath);
        expect(request.url.queryParameters['year'], '2023');
        expect(request.url.queryParameters['examTypeId'], '1');
        expect(request.url.queryParameters['page'], '1');
        expect(request.url.queryParameters['limit'], '10');

        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 101,
                'title': 'Khmer Literature Exam 2023',
                'description': 'Official past exam paper',
                'fileUrl': 'https://storage.example.com/exam2023.pdf',
                'year': 2023,
                'subjectId': 3,
                'examTypeId': 1,
                'subject': {
                  'id': 3,
                  'name': 'Khmer',
                  'nameKm': '?????????????????',
                  'nameEn': 'Khmer Literature',
                },
                'examType': {
                  'id': 1,
                  'name': 'BacII',
                  'description': 'National Exam',
                },
              },
            ],
            'meta': {
              'total': 1,
              'page': 1,
              'limit': 10,
              'totalPages': 1,
              'hasNextPage': false,
              'hasPreviousPage': false,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ResourceApiService(client: mockClient);
      final repo = ResourceRepository(apiService: service);

      final bundle = await repo.fetchResourcesByYear(
        examId: '1',
        year: 2023,
        languageCode: 'km',
      );

      expect(bundle.documents.length, 1);
      final doc = bundle.documents.first;
      expect(doc.id, '101');
      expect(doc.title, 'Khmer Literature Exam 2023');
      expect(doc.type, ResourceDocumentType.pdf);
      expect(doc.subjectName, '?????????????????');
      expect(bundle.subjects.length, 1);
      expect(bundle.subjects.first.id, '3');
      expect(bundle.meta.total, 1);
      expect(bundle.hasMore, isFalse);
    });
  });

  group('Endpoint 3: /api/m/resource-list', () {
    test('fetches through alias endpoint', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, ApiConstants.mobileResourceListPath);
        return http.Response(
          jsonEncode({
            'data': [],
            'meta': {'total': 0, 'page': 1, 'totalPages': 1},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ResourceApiService(client: mockClient);
      final result = await service.fetchMobileResourceList(year: 2023);
      expect(result['data'], isA<List>());
    });
  });

  group('Error Handling', () {
    test('throws friendly message on server error (HTTP 500)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Internal Server Error'}),
          500,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ResourceApiService(client: mockClient);
      expect(
        () => service.fetchMobileResources(year: 2023),
        throwsA(isA<Exception>()),
      );
    });
  });
}

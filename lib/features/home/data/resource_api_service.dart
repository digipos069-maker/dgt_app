import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../domain/models/exam_resource_model.dart';

final resourceApiServiceProvider = Provider<ResourceApiService>((ref) {
  return ResourceApiService();
});

class ResourceApiService {
  ResourceApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Sanitizes query parameters strictly for NestJS `ValidationPipe({ forbidNonWhitelisted: true })`.
  /// Strips any null, empty, or non-whitelisted keys.
  static Map<String, String> sanitizeQueryParams({
    int? year,
    int? examTypeId,
    int? subjectId,
    String? search,
    int? page,
    int? limit,
  }) {
    final params = <String, String>{};

    if (year != null && year >= 1900 && year <= 2100) {
      params['year'] = year.toString();
    }
    if (examTypeId != null && examTypeId > 0) {
      params['examTypeId'] = examTypeId.toString();
    }
    if (subjectId != null && subjectId > 0) {
      params['subjectId'] = subjectId.toString();
    }
    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }
    if (page != null && page >= 1) {
      params['page'] = page.toString();
    }
    if (limit != null && limit >= 1 && limit <= 100) {
      params['limit'] = limit.toString();
    }

    return params;
  }

  /// Endpoint 1: Exam Resource Counts by Year
  /// Path: `GET /api/m/resource-by-year`
  /// Query: `?year=2023` (optional, 1900 to 2100)
  Future<Map<String, dynamic>> fetchResourceByYear({
    int? year,
    String? token,
  }) async {
    final queryParams = sanitizeQueryParams(year: year);
    final baseUri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.mobileResourceByYearPath}');
    final uri = queryParams.isEmpty ? baseUri : baseUri.replace(queryParameters: queryParams);

    return _getJson(uri, token: token, callerName: 'fetchResourceByYear');
  }

  /// Endpoint 2: List Exam Document Resources for Mobile
  /// Path: `GET /api/m/resources`
  Future<Map<String, dynamic>> fetchMobileResources({
    int? year,
    int? examTypeId,
    int? subjectId,
    String? search,
    int page = 1,
    int limit = 10,
    String? token,
  }) async {
    final queryParams = sanitizeQueryParams(
      year: year,
      examTypeId: examTypeId,
      subjectId: subjectId,
      search: search,
      page: page,
      limit: limit,
    );

    final baseUri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.mobileResourcesPath}');
    final uri = queryParams.isEmpty ? baseUri : baseUri.replace(queryParameters: queryParams);

    return _getJson(uri, token: token, callerName: 'fetchMobileResources');
  }

  /// Endpoint 3: Alias for Mobile Resource List
  /// Path: `GET /api/m/resource-list`
  Future<Map<String, dynamic>> fetchMobileResourceList({
    int? year,
    int? examTypeId,
    int? subjectId,
    String? search,
    int page = 1,
    int limit = 10,
    String? token,
  }) async {
    final queryParams = sanitizeQueryParams(
      year: year,
      examTypeId: examTypeId,
      subjectId: subjectId,
      search: search,
      page: page,
      limit: limit,
    );

    final baseUri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.mobileResourceListPath}');
    final uri = queryParams.isEmpty ? baseUri : baseUri.replace(queryParameters: queryParams);

    return _getJson(uri, token: token, callerName: 'fetchMobileResourceList');
  }

  /// Fetches exam types from `/api/exams/types`
  Future<List<ExamResourceModel>> fetchExamTypes({
    String? token,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.examsTypesPath}');
    final jsonBody = await _getJson(uri, token: token, callerName: 'fetchExamTypes');

    final dataList = jsonBody['data'] is List
        ? jsonBody['data'] as List<dynamic>
        : (jsonBody['examTypes'] is List ? jsonBody['examTypes'] as List<dynamic> : (jsonBody is List ? jsonBody as List<dynamic> : []));

    return dataList.map((item) {
      return ExamResourceModel.fromJson(item as Map<String, dynamic>);
    }).toList();
  }

  /// Legacy helper for fetchDocuments, redirects to `/api/m/resources`
  Future<Map<String, dynamic>> fetchDocuments({
    String? token,
    required String examTypeId,
    required int year,
    String? subjectId,
    int page = 1,
    int limit = 10,
  }) async {
    final parsedExamTypeId = int.tryParse(examTypeId);
    final parsedSubjectId = subjectId != null ? int.tryParse(subjectId) : null;

    return fetchMobileResources(
      year: year,
      examTypeId: parsedExamTypeId,
      subjectId: parsedSubjectId,
      page: page,
      limit: limit,
      token: token,
    );
  }

  Future<Map<String, dynamic>> _getJson(
    Uri uri, {
    String? token,
    required String callerName,
  }) async {
    try {
      final headers = {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      final jsonBody = _decodeBody(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = _readMessage(jsonBody) ??
            'Failed to load data (Status ${response.statusCode})';
        throw HttpException(message, uri: uri);
      }

      if (jsonBody is Map<String, dynamic>) {
        return jsonBody;
      } else if (jsonBody is List) {
        return {'data': jsonBody};
      } else {
        return {'data': []};
      }
    } on SocketException catch (e) {
      throw SocketException('Network error: please check your connection. (${e.message})');
    } on TimeoutException {
      throw TimeoutException('Request timed out. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  dynamic _decodeBody(String body) {
    if (body.isEmpty) return {};
    try {
      return jsonDecode(body);
    } catch (_) {
      return {};
    }
  }

  String? _readMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      if (body['message'] is String) return body['message'] as String;
      if (body['message'] is List) {
        return (body['message'] as List).join(', ');
      }
      if (body['error'] is String) return body['error'] as String;
    }
    return null;
  }
}


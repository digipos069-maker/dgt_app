import 'dart:convert';
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

  Future<List<ExamResourceModel>> fetchExamTypes({
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.examsTypesPath}');
    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 15));

    final jsonBody = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_readMessage(jsonBody) ?? 'Failed to load exam types (Status ${response.statusCode})');
    }

    // Handle both cases: an array at the root, or { "data": [...] }
    final dataList = jsonBody is List ? jsonBody : (jsonBody['data'] as List<dynamic>? ?? []);
    
    return dataList.map((item) {
      return ExamResourceModel.fromJson(item as Map<String, dynamic>);
    }).toList();
  }

  Future<Map<String, dynamic>> fetchDocuments({
    required String token,
    required String examTypeId,
    required int year,
    String? subjectId,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = {
      'examTypeId': examTypeId,
      'year': year.toString(),
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (subjectId != null && subjectId.isNotEmpty) {
      queryParams['subjectId'] = subjectId;
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.examsDocumentsPath}')
        .replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 15));

    final jsonBody = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_readMessage(jsonBody) ?? 'Failed to load documents (Status ${response.statusCode})');
    }

    return jsonBody;
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
      if (body['error'] is String) return body['error'] as String;
    }
    return null;
  }
}

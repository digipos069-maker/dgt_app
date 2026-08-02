import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../domain/models/basic_lesson_model.dart';
import '../domain/models/basic_course_model.dart';

final basicCourseApiServiceProvider = Provider<BasicCourseApiService>((ref) {
  return BasicCourseApiService();
});

class BasicCourseApiService {
  BasicCourseApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<BasicLessonBundle> fetchBasicContent({
    required String token,
    required String subjectId,
    required String courseId, // The string ID used in the app
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.basicContentPath}?subjectId=$subjectId&page=1&limit=100');
    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 15));

    final jsonBody = _decodeBody(response.body);
    
    print('DEBUG API: ${response.statusCode} ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_readMessage(jsonBody) ?? 'Failed to load basic content (Status ${response.statusCode})');
    }

    final dataList = jsonBody['data'] as List<dynamic>? ?? [];
    
    // We parse the first item to get the subject details, if any exist.
    // Otherwise we just return a placeholder course model.
    BasicCourseModel course;
    if (dataList.isNotEmpty && dataList.first['subject'] != null) {
      final subjectObj = dataList.first['subject'];
      course = BasicCourseModel(
        id: courseId,
        name: subjectObj['nameEn']?.toString() ?? 'Course',
        thumbnail: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=1200&q=80', // Fallback
        description: 'Basic Content for ${subjectObj['nameEn']}',
      );
    } else {
      course = BasicCourseModel(
        id: courseId,
        name: 'Basic Course',
        thumbnail: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=1200&q=80',
        description: 'Basic Course',
      );
    }

    final lessons = dataList.map((item) {
      return BasicLessonModel.fromJson(item as Map<String, dynamic>, courseId: courseId);
    }).toList();

    return BasicLessonBundle(
      course: course,
      lessons: lessons,
    );
  }

  Future<Map<String, dynamic>> fetchBasicContentDetail({
    required String token,
    required String slug,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.basicContentPath}/slug/$slug');
    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 15));

    final jsonBody = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_readMessage(jsonBody) ?? 'Failed to load basic content detail (Status ${response.statusCode})');
    }

    return jsonBody;
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.isEmpty) return {};
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  String? _readMessage(Map<String, dynamic> body) {
    if (body['message'] is String) return body['message'] as String;
    if (body['error'] is String) return body['error'] as String;
    return null;
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/utils/app_exception.dart';
import '../domain/models/daily_goal_model.dart';

class DailyGoalApiService {
  DailyGoalApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<DailyGoalModel> fetchDailyGoal(String token) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dailyGoalPath}');
    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 15));

    final jsonBody = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(_readMessage(jsonBody) ?? 'Failed to load daily goal');
    }

    return DailyGoalModel.fromJson(jsonBody['data'] ?? jsonBody);
  }

  Future<void> updateDailyGoal(String token, {required int targetVideos, required int targetQuizzes}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dailyGoalPath}');
    final response = await _client.put(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'targetVideos': targetVideos,
        'targetQuizzes': targetQuizzes,
      }),
    ).timeout(const Duration(seconds: 15));

    final jsonBody = _decodeBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(_readMessage(jsonBody) ?? 'Failed to update daily goal');
    }
  }

  Future<void> updateFcmToken(String token, String fcmToken) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.fcmTokenPath}');
    final response = await _client.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'fcmToken': fcmToken,
      }),
    ).timeout(const Duration(seconds: 15));

    final jsonBody = _decodeBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(_readMessage(jsonBody) ?? 'Failed to update FCM token');
    }
  }

  Future<void> completeVideo(String token, int videoId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.videoCompletionPath}');
    final response = await _client.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'videoId': videoId,
      }),
    ).timeout(const Duration(seconds: 15));

    final jsonBody = _decodeBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(_readMessage(jsonBody) ?? 'Failed to complete video');
    }
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return <String, dynamic>{};
  }

  String? _readMessage(Map<String, dynamic> json) {
    final message = json['message'] ?? json['error'];
    return message is String && message.trim().isNotEmpty ? message : null;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/ai_tutor_lesson_ref.dart';
import '../domain/models/ai_tutor_message.dart';
import '../domain/models/ai_tutor_stream_event.dart';
import 'ai_tutor_api_service.dart';

final aiTutorRepositoryProvider = Provider<AiTutorRepository>(
  (ref) => AiTutorRepository(AiTutorApiService()),
);

class AiTutorRepository {
  const AiTutorRepository(this._apiService);

  final AiTutorApiService _apiService;

  /// Only the most recent turns are sent; the server trims further.
  static const maxHistory = 12;

  Future<AiTutorLessonSearchResult> searchLessons({
    required String token,
    required AiTutorLessonQuery query,
  }) async {
    final json = await _apiService.fetchLessons(
      token: token,
      query: query.query,
      allGrades: query.allGrades,
    );
    return AiTutorLessonSearchResult.fromJson(json);
  }

  Stream<AiTutorStreamEvent> askStream({
    required String token,
    required String message,
    required List<AiTutorMessage> history,
    int? tutorialId,
  }) {
    final usable = history
        .where((item) => !item.isError && item.text.trim().isNotEmpty)
        .toList(growable: false);
    final trimmed = usable.length > maxHistory
        ? usable.sublist(usable.length - maxHistory)
        : usable;

    return _apiService.streamMessage(
      token: token,
      message: message,
      tutorialId: tutorialId,
      history: trimmed.map((item) => item.toHistoryJson()).toList(),
    );
  }
}

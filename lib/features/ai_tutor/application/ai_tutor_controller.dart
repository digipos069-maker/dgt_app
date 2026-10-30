import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_exception.dart';
import '../../auth/application/auth_controller.dart';
import '../data/ai_tutor_repository.dart';
import '../domain/models/ai_tutor_chat_state.dart';
import '../domain/models/ai_tutor_lesson_ref.dart';
import '../domain/models/ai_tutor_message.dart';
import '../domain/models/ai_tutor_stream_event.dart';
import '../domain/models/ai_tutor_usage.dart';

/// Keep a conversation for a while after the student leaves the page,
/// so going back to the video and returning doesn't wipe the chat.
const aiTutorChatCacheDuration = Duration(minutes: 30);

/// How often streamed text is revealed on screen (~30 fps).
const _revealInterval = Duration(milliseconds: 33);

class AiTutorController extends Notifier<AiTutorChatState> {
  AiTutorController(this.session);

  final AiTutorSession session;
  int _idSeed = 0;

  // --- active reply ---
  StreamSubscription<AiTutorStreamEvent>? _subscription;
  Timer? _revealTimer;
  String? _activeId;

  /// Bumped for every new question; late events from an older stream are ignored.
  int _generation = 0;

  /// Text received from the server but not yet shown (revealed gradually).
  String _pending = '';
  bool _streamFinished = false;
  String? _streamErrorKey;

  @override
  AiTutorChatState build() {
    final cacheLink = ref.keepAlive();
    Timer? cacheTimer;
    ref.onCancel(() {
      cacheTimer = Timer(aiTutorChatCacheDuration, cacheLink.close);
    });
    ref.onResume(() {
      cacheTimer?.cancel();
      cacheTimer = null;
    });
    ref.onDispose(() {
      cacheTimer?.cancel();
      _subscription?.cancel();
      _revealTimer?.cancel();
    });

    return AiTutorChatState(attachedLesson: session.initialLesson);
  }

  /// Grounds the following answers in [lesson] (can be changed mid-chat).
  ///
  /// If the student had asked a question before choosing a lesson, that
  /// question is answered right away so they don't have to type it again.
  void attachLesson(AiTutorLessonRef lesson) {
    if (state.isSending) return;
    state = state.copyWith(attachedLesson: lesson);

    final messages = state.messages;
    if (messages.length >= 2 &&
        messages.last.requiresLesson &&
        messages[messages.length - 2].isUser) {
      final pendingQuestion = messages[messages.length - 2].text;
      state = state.copyWith(messages: messages.sublist(0, messages.length - 2));
      unawaited(send(pendingQuestion));
    }
  }

  /// Back to general study help.
  void detachLesson() {
    if (state.isSending) return;
    state = state.copyWith(clearAttachedLesson: true);
  }

  Future<void> send(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || state.isSending) return;

    final history = state.messages;

    // A lesson must be chosen before the tutor answers anything.
    if (state.attachedLesson == null) {
      state = state.copyWith(
        messages: [
          ...history.where((message) => !message.requiresLesson),
          AiTutorMessage(id: _nextId(), role: AiTutorRole.user, text: text),
          AiTutorMessage(
            id: _nextId(),
            role: AiTutorRole.model,
            text: '',
            requiresLesson: true,
          ),
        ],
      );
      return;
    }

    final reply = AiTutorMessage(
      id: _nextId(),
      role: AiTutorRole.model,
      text: '',
      isStreaming: true,
    );
    state = state.copyWith(
      messages: [
        ...history,
        AiTutorMessage(id: _nextId(), role: AiTutorRole.user, text: text),
        reply,
      ],
      isSending: true,
    );

    final generation = ++_generation;
    _activeId = reply.id;
    _pending = '';
    _streamFinished = false;
    _streamErrorKey = null;

    final String token;
    try {
      token = _readToken();
    } on AppException catch (error) {
      _finishStream(errorKey: _errorKeyFor(error));
      return;
    }

    _subscription = ref
        .read(aiTutorRepositoryProvider)
        .askStream(
          token: token,
          message: text,
          history: history,
          tutorialId: state.attachedLesson?.id,
        )
        .listen(
          (event) {
            if (generation != _generation) return;
            switch (event) {
              case AiTutorDelta(:final text):
                _pending += text;
                _startRevealing();
              case AiTutorDone(:final usage):
                if (usage != null) {
                  ref.read(aiTutorUsageProvider.notifier).set(usage);
                }
              case AiTutorStreamFailure():
                _finishStream(errorKey: 'aiTutorErrorGeneric');
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            if (generation != _generation) return;
            developer.log(
              'AI tutor stream failed',
              name: 'dgt.ai_tutor',
              error: error,
              stackTrace: stackTrace,
            );
            _finishStream(errorKey: _errorKeyFor(error));
          },
          onDone: () {
            if (generation == _generation) _finishStream();
          },
          cancelOnError: true,
        );
  }

  /// "Stop generating": keeps what is already on screen and ends the reply.
  void stop() {
    if (_activeId == null) return;
    _generation++;
    _pending = '';
    _finishStream();
  }

  /// Re-sends the question that produced the failed reply [errorMessageId].
  Future<void> retry(String errorMessageId) async {
    final messages = state.messages;
    final errorIndex = messages.indexWhere((m) => m.id == errorMessageId);
    if (errorIndex <= 0 || state.isSending) return;
    final question = messages[errorIndex - 1];
    if (!question.isUser) return;

    state = state.copyWith(messages: messages.sublist(0, errorIndex - 1));
    await send(question.text);
  }

  /// New chat: clears messages but keeps the attached lesson.
  void clear() {
    stop();
    state = AiTutorChatState(attachedLesson: state.attachedLesson);
  }

  /// Marks the stream as over. The reply is finalized once all pending text
  /// has been revealed, so the typing animation never jumps to the end.
  void _finishStream({String? errorKey}) {
    _streamFinished = true;
    _streamErrorKey ??= errorKey;
    if (_pending.isEmpty) {
      _finalize();
    } else {
      _startRevealing();
    }
  }

  void _startRevealing() {
    _revealTimer ??= Timer.periodic(_revealInterval, (_) => _revealTick());
  }

  void _revealTick() {
    if (!ref.mounted) return;
    if (_pending.isNotEmpty) {
      // Reveal faster when a big chunk is waiting, so we never fall far behind.
      var count = math.max(2, (_pending.length / 8).ceil());
      count = math.min(count, _pending.length);
      // Don't split a UTF-16 surrogate pair (emoji etc.).
      if (count < _pending.length && _isHighSurrogate(_pending.codeUnitAt(count - 1))) {
        count++;
      }
      final chunk = _pending.substring(0, count);
      _pending = _pending.substring(count);
      _updateActive((message) => message.copyWith(text: message.text + chunk));
    }
    if (_pending.isEmpty && _streamFinished) _finalize();
  }

  void _finalize() {
    _revealTimer?.cancel();
    _revealTimer = null;
    // Cancelling aborts the HTTP request, so the server stops generating too.
    _subscription?.cancel();
    _subscription = null;
    final activeId = _activeId;
    _activeId = null;
    if (!ref.mounted || activeId == null) return;

    final errorKey = _streamErrorKey;
    final messages = <AiTutorMessage>[];
    for (final message in state.messages) {
      if (message.id != activeId) {
        messages.add(message);
      } else if (message.text.trim().isNotEmpty) {
        // Keep partial text even if the connection dropped half-way.
        messages.add(message.copyWith(isStreaming: false));
      } else if (errorKey != null) {
        messages.add(message.copyWith(isStreaming: false, errorKey: errorKey));
      }
      // else: stopped before any text arrived → drop the empty reply.
    }
    state = state.copyWith(
      messages: messages,
      isSending: false,
    );
    // Out of tokens: reload the allowance so the usage bar shows the reset date.
    if (errorKey == 'aiTutorLimitReached') {
      ref.read(aiTutorUsageProvider.notifier).refresh();
    }
  }

  void _updateActive(AiTutorMessage Function(AiTutorMessage) update) {
    final activeId = _activeId;
    if (activeId == null) return;
    state = state.copyWith(
      messages: [
        for (final message in state.messages)
          message.id == activeId ? update(message) : message,
      ],
    );
  }

  String _readToken() {
    final user = switch (ref.read(authControllerProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final token = user?.token;
    if (token == null || token.isEmpty) {
      throw const AppException('Authentication is required', statusCode: 401);
    }
    return token;
  }

  String _errorKeyFor(Object error) {
    if (error is AppException) {
      return switch (error.statusCode) {
        429 => 'aiTutorLimitReached',
        401 || 403 => 'aiTutorSignInAgain',
        408 => 'aiTutorTimeout',
        _ => 'aiTutorErrorGeneric',
      };
    }
    return 'aiTutorErrorGeneric';
  }

  bool _isHighSurrogate(int codeUnit) => codeUnit >= 0xD800 && codeUnit <= 0xDBFF;

  String _nextId() => '${DateTime.now().microsecondsSinceEpoch}-${_idSeed++}';
}

/// The student's monthly AI tutor token allowance.
/// Loaded from the server, then updated after every answer.
class AiTutorUsageNotifier extends AsyncNotifier<AiTutorUsage> {
  @override
  Future<AiTutorUsage> build() {
    final user = switch (ref.watch(authControllerProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final token = user?.token;
    if (token == null || token.isEmpty) {
      throw const AppException('Authentication is required', statusCode: 401);
    }
    return ref.read(aiTutorRepositoryProvider).getUsage(token: token);
  }

  void set(AiTutorUsage usage) => state = AsyncData(usage);

  void refresh() => ref.invalidateSelf();
}

final aiTutorUsageProvider =
    AsyncNotifierProvider.autoDispose<AiTutorUsageNotifier, AiTutorUsage>(
      AiTutorUsageNotifier.new,
    );

/// Lessons for the "Add lesson" picker (student's grade by default).
final aiTutorLessonSearchProvider = FutureProvider.autoDispose
    .family<AiTutorLessonSearchResult, AiTutorLessonQuery>((ref, query) {
      final user = switch (ref.watch(authControllerProvider)) {
        AsyncData(:final value) => value,
        _ => null,
      };
      final token = user?.token;
      if (token == null || token.isEmpty) {
        throw const AppException('Authentication is required', statusCode: 401);
      }
      return ref
          .watch(aiTutorRepositoryProvider)
          .searchLessons(token: token, query: query);
    });

final aiTutorControllerProvider = NotifierProvider.autoDispose
    .family<AiTutorController, AiTutorChatState, AiTutorSession>(
      (session) => AiTutorController(session),
    );

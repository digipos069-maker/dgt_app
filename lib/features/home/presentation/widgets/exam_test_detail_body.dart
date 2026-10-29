import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../theme/app_colors.dart';
import '../../../auth/application/auth_controller.dart';
import '../../application/resource_controller.dart';
import '../../data/resource_repository.dart';
import '../../domain/models/exam_test_model.dart';
import '../../domain/models/quiz_models.dart';
import 'exam_test_list_body.dart';
import 'quiz/quiz_question_dispatcher.dart';

enum _ExamPhase { intro, inProgress, finished }

/// Loads `GET /api/m/exam-tests/:id` and runs the test:
/// intro → timed test (answer everything, submit once) → result + review.
///
/// Submitting sends the answers to `POST /api/m/exam-tests/:id/submit`, which
/// grades and saves the attempt. If that fails (offline, not logged in), the
/// test is graded on the device from `quizData` instead (see `_grade()`).
class ExamTestDetailBody extends ConsumerWidget {
  const ExamTestDetailBody({required this.testId, super.key});

  final String testId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(examTestDetailProvider(testId));
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        textTheme: GoogleFonts.battambangTextTheme(theme.textTheme),
      ),
      child: detailState.when(
        data: (detail) => _ExamTestRunner(
          // Fresh runner state whenever the test is reloaded.
          key: ValueKey(detail),
          detail: detail,
        ),
        error: (_, _) => Scaffold(
          appBar: AppBar(title: Text(context.l10n.text('examTestTitle'))),
          body: _DetailError(
            onRetry: () => ref.invalidate(examTestDetailProvider(testId)),
          ),
        ),
        loading: () => Scaffold(
          appBar: AppBar(title: Text(context.l10n.text('examTestTitle'))),
          body: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _ExamTestRunner extends ConsumerStatefulWidget {
  const _ExamTestRunner({required this.detail, super.key});

  final ExamTestDetail detail;

  @override
  ConsumerState<_ExamTestRunner> createState() => _ExamTestRunnerState();
}

class _ExamTestRunnerState extends ConsumerState<_ExamTestRunner> {
  _ExamPhase _phase = _ExamPhase.intro;

  // Answers keyed by question id.
  final Map<String, String> _choiceAnswers = {};
  final Map<String, Map<String, String>> _matchingAnswers = {};
  final Map<String, String?> _dragAnswers = {};

  // Set after submitting.
  Map<String, bool> _results = const {};
  Map<String, String?> _correctOptionIds = const {};
  bool _isSubmitting = false;

  /// Server-graded result; null when the attempt could not be saved and
  /// the result shown is the on-device fallback.
  ExamTestSubmitResult? _serverResult;

  Timer? _timer;
  DateTime? _startedAt;
  DateTime? _endsAt;
  Duration _remaining = Duration.zero;
  Duration _timeUsed = Duration.zero;

  final ScrollController _scrollController = ScrollController();

  /// Turned on when the student taps Submit with blank answers, so every
  /// unanswered question is highlighted until it gets an answer.
  bool _showMissing = false;
  final Map<String, GlobalKey> _questionKeys = {};

  ExamTestModel get _test => widget.detail.test;
  List<ExamTestQuestion> get _questions => widget.detail.questions;

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Flow ────────────────────────────────────────────────────────────────

  void _start() {
    _timer?.cancel();
    final now = DateTime.now();
    setState(() {
      _choiceAnswers.clear();
      _matchingAnswers.clear();
      _dragAnswers.clear();
      _results = const {};
      _correctOptionIds = const {};
      _serverResult = null;
      _isSubmitting = false;
      _showMissing = false;
      _startedAt = now;
      _endsAt = _test.durationMinutes > 0
          ? now.add(Duration(minutes: _test.durationMinutes))
          : null;
      _remaining = _endsAt?.difference(now) ?? Duration.zero;
      _phase = _ExamPhase.inProgress;
    });

    if (_endsAt != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
    _scrollToTop();
  }

  void _tick() {
    final endsAt = _endsAt;
    if (endsAt == null || !mounted) return;
    final remaining = endsAt.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _finish(timeUp: true);
    } else {
      setState(() => _remaining = remaining);
    }
  }

  /// Manual submit is blocked while any question is blank: the blank ones
  /// are highlighted and the first one is scrolled into view.
  /// (Time-up still auto-submits whatever has been answered.)
  void _submit() {
    final missing = _questions
        .where((q) => !_isAnswered(q.question))
        .toList();
    if (missing.isEmpty) {
      _finish();
      return;
    }

    setState(() => _showMissing = true);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            context.l10n
                .text('examTestAnswerAllError')
                .replaceAll('{count}', '${missing.length}'),
          ),
        ),
      );

    final firstContext = _questionKeys[missing.first.question.id]?.currentContext;
    if (firstContext != null) {
      Scrollable.ensureVisible(
        firstContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    }
  }

  Future<void> _finish({bool timeUp = false}) async {
    if (_phase != _ExamPhase.inProgress || _isSubmitting) return;
    _timer?.cancel();
    var timeUsed = DateTime.now().difference(_startedAt ?? DateTime.now());
    if (_endsAt != null && timeUp) {
      timeUsed = Duration(minutes: _test.durationMinutes);
    }
    setState(() {
      _isSubmitting = true;
      _remaining = Duration.zero;
    });

    // 1. Send to the server (grades + saves the attempt).
    final server = await _submitToServer();
    if (!mounted) return;
    if (server != null) {
      // So "My study" shows this attempt next time it is opened.
      ref.invalidate(myExamTestAttemptsProvider);
    }

    // 2. Fallback / review helpers from the local copy of quizData.
    final local = _grade();

    setState(() {
      _isSubmitting = false;
      _serverResult = server;
      if (server != null) {
        _results = {
          for (final item in _questions)
            item.question.id:
                server.results[_quizIdOf(item.question)]?.isCorrect ?? false,
        };
        _correctOptionIds = {
          for (final item in _questions)
            if (item.question.type == QuizType.multipleChoice)
              item.question.id:
                  _findCorrectOptionId(
                    item.question,
                    server.results[_quizIdOf(item.question)]?.correctAnswer
                        ?.toString(),
                  ) ??
                  local.correctOptionIds[item.question.id],
        };
      } else {
        _results = local.results;
        _correctOptionIds = local.correctOptionIds;
      }
      _timeUsed = timeUsed;
      _phase = _ExamPhase.finished;
    });
    _scrollToTop();

    final messages = [
      if (timeUp) context.l10n.text('examTestTimeUp'),
      if (server == null) context.l10n.text('examTestNotSaved'),
    ];
    if (messages.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(messages.join('\n'))));
    }
  }

  int? _quizIdOf(QuizQuestionModel q) => q.quizId ?? int.tryParse(q.id);

  /// `[{quizId, answer}]` in the shapes the backend grades:
  /// choice → option id ("A"/value), drag & drop → dropped text,
  /// matching → {stemId: optionId}. Blank questions are left out.
  List<Map<String, Object?>> _answerPayload() {
    final payload = <Map<String, Object?>>[];
    for (final item in _questions) {
      final q = item.question;
      final quizId = _quizIdOf(q);
      if (quizId == null) continue;
      final Object? answer = switch (q.type) {
        QuizType.multipleChoice => _choiceAnswers[q.id],
        QuizType.dragAndDrop => _dragAnswers[q.id],
        QuizType.matching =>
          (_matchingAnswers[q.id]?.isNotEmpty ?? false)
              ? _matchingAnswers[q.id]
              : null,
      };
      if (answer == null || (answer is String && answer.isEmpty)) continue;
      payload.add({'quizId': quizId, 'answer': answer});
    }
    return payload;
  }

  Future<ExamTestSubmitResult?> _submitToServer() async {
    final authState = ref.read(authControllerProvider);
    final token = switch (authState) {
      AsyncData(:final value) => value?.token,
      _ => null,
    };
    if (token == null || token.isEmpty) return null;

    try {
      return await ref
          .read(resourceRepositoryProvider)
          .submitExamTest(
            testId: _test.id,
            token: token,
            answers: _answerPayload(),
            startedAt: _startedAt,
          );
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleLeave() async {
    final ok = await _confirm(
      title: context.l10n.text('examTestLeaveTitle'),
      message: context.l10n.text('examTestLeaveMessage'),
      confirmLabel: context.l10n.text('examTestLeave'),
      destructive: true,
    );
    if (ok == true && mounted) {
      _timer?.cancel();
      // pop() (not maybePop) so PopScope doesn't ask a second time.
      Navigator.of(context).pop();
    }
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.text('examTestCancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: destructive
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    });
  }

  // ── Grading ─────────────────────────────────────────────────────────────

  bool _isAnswered(QuizQuestionModel q) {
    return switch (q.type) {
      QuizType.multipleChoice => _choiceAnswers[q.id] != null,
      QuizType.matching =>
        (_matchingAnswers[q.id]?.length ?? 0) >=
            (q.matchingData?.stems.length ?? 1),
      QuizType.dragAndDrop => (_dragAnswers[q.id] ?? '').isNotEmpty,
    };
  }

  int get _answeredCount =>
      _questions.where((q) => _isAnswered(q.question)).length;

  ({Map<String, bool> results, Map<String, String?> correctOptionIds})
  _grade() {
    final results = <String, bool>{};
    final correctIds = <String, String?>{};

    for (final item in _questions) {
      final q = item.question;
      switch (q.type) {
        case QuizType.multipleChoice:
          final correctId = _findCorrectOptionId(q, q.correctAnswer);
          correctIds[q.id] = correctId;
          final selected = _choiceAnswers[q.id];
          results[q.id] = selected != null && selected == correctId;
        case QuizType.matching:
          final data = q.matchingData;
          results[q.id] =
              data != null &&
              data.areAllMatchesCorrect(_matchingAnswers[q.id] ?? const {});
        case QuizType.dragAndDrop:
          final data = q.dragAndDropData;
          final dropped = _dragAnswers[q.id];
          results[q.id] =
              data != null && dropped != null && data.isCorrect(dropped);
      }
    }
    return (results: results, correctOptionIds: correctIds);
  }

  String? _findCorrectOptionId(QuizQuestionModel q, String? correctAnswer) {
    final correct = correctAnswer?.trim();
    if (correct == null || correct.isEmpty) return null;
    String normalize(String v) => v.trim().replaceAll(RegExp(r'\s+'), '');

    for (final option in q.options) {
      if (option.id.toUpperCase() == correct.toUpperCase()) return option.id;
    }
    for (final option in q.options) {
      if (normalize(option.labelKey) == normalize(correct)) return option.id;
    }
    return null;
  }

  int get _earnedPoints => _questions
      .where((q) => _results[q.question.id] == true)
      .fold(0, (sum, q) => sum + q.points);

  /// Earned points scaled to the test's `totalScore` (e.g. 7/10 pts → 70/100).
  double get _scaledScore {
    final totalPoints = widget.detail.totalPoints;
    if (totalPoints <= 0) return 0;
    final outOf = _test.totalScore > 0 ? _test.totalScore : totalPoints;
    return _earnedPoints / totalPoints * outOf;
  }

  bool get _passed => _scaledScore >= _test.passingScore;

  int get _resultTotalScore =>
      _serverResult?.totalScore ??
      (_test.totalScore > 0 ? _test.totalScore : widget.detail.totalPoints);

  // ── UI ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final inProgress = _phase == _ExamPhase.inProgress;

    return PopScope(
      canPop: !inProgress,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleLeave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _test.title.isNotEmpty
                ? _test.title
                : context.l10n.text('examTestTitle'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: Column(
          children: [
            if (inProgress)
              _ProgressHeader(
                remaining: _endsAt == null ? null : _remaining,
                answered: _answeredCount,
                total: _questions.length,
              ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.spacing12,
                  AppSizes.spacing16,
                  AppSizes.spacing12,
                  AppSizes.spacing32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: switch (_phase) {
                      _ExamPhase.intro => _IntroView(
                        detail: widget.detail,
                        onStart: _questions.isEmpty ? null : _start,
                      ),
                      _ExamPhase.inProgress => _buildQuestions(review: false),
                      _ExamPhase.finished => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ResultCard(
                            score: _serverResult?.score ?? _scaledScore,
                            totalScore: _resultTotalScore,
                            passingScore:
                                _serverResult?.passingScore ??
                                _test.passingScore,
                            passed: _serverResult?.passed ?? _passed,
                            savedToServer: _serverResult != null,
                            correct: _results.values.where((r) => r).length,
                            incorrect: _questions
                                .where(
                                  (q) =>
                                      _results[q.question.id] == false &&
                                      _isAnswered(q.question),
                                )
                                .length,
                            unanswered: _questions.length - _answeredCount,
                            timeUsed: _timeUsed,
                            onRetake: _start,
                          ),
                          const SizedBox(height: AppSizes.spacing24),
                          Text(
                            context.l10n.text('examTestReview'),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: AppSizes.spacing12),
                          _buildQuestions(review: true),
                        ],
                      ),
                    },
                  ),
                ),
              ),
            ),
            if (inProgress)
              _SubmitBar(
                answered: _answeredCount,
                total: _questions.length,
                isSubmitting: _isSubmitting,
                onSubmit: _submit,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestions({required bool review}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, item) in _questions.indexed) ...[
          if (index > 0) const SizedBox(height: AppSizes.spacing12),
          _QuestionCard(
            key: _questionKeys.putIfAbsent(item.question.id, GlobalKey.new),
            points: item.points,
            missing: !review && _showMissing && !_isAnswered(item.question),
            result: review ? _results[item.question.id] : null,
            child: QuizQuestionDispatcher(
              // Rebuild the widget fresh on retake so local state resets.
              key: ValueKey(
                '${item.question.id}-${_startedAt?.millisecondsSinceEpoch}',
              ),
              number: index + 1,
              question: item.question,
              selectedAnswer: _choiceAnswers[item.question.id],
              onAnswerChanged: review
                  ? null
                  : (optionId) => setState(
                      () => _choiceAnswers[item.question.id] = optionId,
                    ),
              matchingMatches: _matchingAnswers[item.question.id],
              onMatchingChanged: review
                  ? null
                  : (matches) => setState(
                      () => _matchingAnswers[item.question.id] =
                          Map<String, String>.from(matches),
                    ),
              droppedValue: _dragAnswers[item.question.id],
              onDroppedChanged: review
                  ? null
                  : (value) => setState(
                      () => _dragAnswers[item.question.id] = value,
                    ),
              // onSubmit left null → no per-question submit buttons.
              isSubmitted: review,
              isCorrect: review ? _results[item.question.id] : null,
              correctAnswer: review
                  ? _correctOptionIds[item.question.id]
                  : null,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Pieces ────────────────────────────────────────────────────────────────

class _IntroView extends StatelessWidget {
  const _IntroView({required this.detail, required this.onStart});

  final ExamTestDetail detail;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;
    final test = detail.test;
    final subjectName = test.subjectName(
      Localizations.localeOf(context).languageCode,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.spacing20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            color: colors.primary,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.assignment_outlined,
                color: colors.onPrimary,
                size: 36,
              ),
              const SizedBox(height: AppSizes.spacing12),
              Text(
                test.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (test.description.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  test.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
              const SizedBox(height: AppSizes.spacing12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (subjectName.isNotEmpty) _WhiteTag(subjectName),
                  if (test.grade != null && test.grade!.number > 0)
                    _WhiteTag(
                      l10n
                          .text('examTestGrade')
                          .replaceAll('{grade}', '${test.grade!.number}'),
                    ),
                  if (test.track.isNotEmpty) _WhiteTag(test.track),
                  if (test.examTypeName.isNotEmpty)
                    _WhiteTag(test.examTypeName),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spacing16),
        ExamTestStatsStrip(
          margin: EdgeInsets.zero,
          questionCount: detail.questions.length,
          durationMinutes: test.durationMinutes,
          totalScore: test.totalScore,
        ),
        const SizedBox(height: AppSizes.spacing16),
        Container(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.text('examTestRulesTitle'),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.secondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSizes.spacing8),
              _RuleRow(
                icon: Icons.timer_outlined,
                text: l10n
                    .text('examTestRuleTime')
                    .replaceAll('{minutes}', '${test.durationMinutes}'),
              ),
              _RuleRow(
                icon: Icons.flag_outlined,
                text: l10n
                    .text('examTestPassingScore')
                    .replaceAll('{pass}', '${test.passingScore}')
                    .replaceAll('{total}', '${test.totalScore}'),
              ),
              _RuleRow(
                icon: Icons.task_alt_outlined,
                text: l10n.text('examTestRuleSubmit'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spacing24),
        if (detail.questions.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spacing12),
            child: Text(
              l10n.text('examTestNoQuestions'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(l10n.text('examTestStart')),
          ),
        ),
      ],
    );
  }
}

class _WhiteTag extends StatelessWidget {
  const _WhiteTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: onPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: AppSizes.spacing8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.remaining,
    required this.answered,
    required this.total,
  });

  /// null when the test has no time limit.
  final Duration? remaining;
  final int answered;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isLow = remaining != null && remaining!.inSeconds <= 60;
    final timerColor = isLow ? colors.error : colors.secondary;

    return Material(
      color: colors.surface,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(
          children: [
            Row(
              children: [
                if (remaining != null) ...[
                  Icon(Icons.timer_outlined, size: 20, color: timerColor),
                  const SizedBox(width: 6),
                  Text(
                    _formatDuration(remaining!),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: timerColor,
                      fontWeight: FontWeight.w900,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  context.l10n
                      .text('examTestAnswered')
                      .replaceAll('{answered}', '$answered')
                      .replaceAll('{total}', '$total'),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : answered / total,
                minHeight: 6,
                color: colors.primary,
                backgroundColor: colors.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({
    required this.answered,
    required this.total,
    required this.onSubmit,
    this.isSubmitting = false,
  });

  final int answered;
  final int total;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final remaining = total - answered;
    final canSubmit = total > 0 && remaining <= 0;

    return Material(
      color: colors.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!canSubmit) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        context.l10n
                            .text('examTestAnswerAllHint')
                            .replaceAll('{count}', '$remaining'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                height: 50,
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  // Always tappable; _submit() validates and highlights
                  // blank questions instead of submitting.
                  onPressed: total > 0 && !isSubmitting ? onSubmit : null,
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    '${context.l10n.text('examTestSubmit')} ($answered/$total)',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.points,
    required this.child,
    this.result,
    this.missing = false,
    super.key,
  });

  final int points;
  final Widget child;

  /// null while taking the test; true/false in review.
  final bool? result;

  /// Blank answer after the student tried to submit.
  final bool missing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final borderColor = switch (result) {
      true => AppColors.success,
      false => AppColors.error,
      null => missing ? colors.error : colors.outlineVariant,
    };

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: borderColor,
          width: result == null && !missing ? 1 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (result != null)
                Icon(
                  result! ? Icons.check_circle : Icons.cancel,
                  size: 18,
                  color: borderColor,
                ),
              if (missing) ...[
                Icon(Icons.error_outline, size: 18, color: colors.error),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    context.l10n.text('examTestAnswerRequired'),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  context.l10n
                      .text('examTestPoints')
                      .replaceAll('{points}', '$points'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing8),
          child,
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.savedToServer,
    required this.score,
    required this.totalScore,
    required this.passingScore,
    required this.passed,
    required this.correct,
    required this.incorrect,
    required this.unanswered,
    required this.timeUsed,
    required this.onRetake,
  });

  final bool savedToServer;
  final double score;
  final int totalScore;
  final int passingScore;
  final bool passed;
  final int correct;
  final int incorrect;
  final int unanswered;
  final Duration timeUsed;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;
    final accent = passed ? AppColors.success : AppColors.error;
    final ratio = totalScore > 0 ? (score / totalScore).clamp(0.0, 1.0) : 0.0;
    final scoreLabel = score == score.roundToDouble()
        ? score.toInt().toString()
        : score.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.48),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 132,
            height: 132,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 10,
                  color: colors.primary,
                  backgroundColor: colors.surfaceContainerHighest,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        scoreLabel,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: colors.secondary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '/ $totalScore',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              l10n.text(passed ? 'examTestPassed' : 'examTestFailed'),
              style: theme.textTheme.titleSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            l10n
                .text('examTestPassingScore')
                .replaceAll('{pass}', '$passingScore')
                .replaceAll('{total}', '$totalScore'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                savedToServer
                    ? Icons.cloud_done_outlined
                    : Icons.cloud_off_outlined,
                size: 16,
                color: savedToServer ? AppColors.success : colors.error,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  l10n.text(
                    savedToServer ? 'examTestSaved' : 'examTestNotSaved',
                  ),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: savedToServer ? AppColors.success : colors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing16),
          Row(
            children: [
              _ResultStat(
                value: '$correct',
                label: l10n.text('examTestCorrect'),
                color: AppColors.success,
              ),
              _ResultStat(
                value: '$incorrect',
                label: l10n.text('examTestIncorrect'),
                color: AppColors.error,
              ),
              _ResultStat(
                value: '$unanswered',
                label: l10n.text('examTestUnanswered'),
                color: colors.onSurfaceVariant,
              ),
              _ResultStat(
                value: _formatDuration(timeUsed),
                label: l10n.text('examTestTimeUsed'),
                color: colors.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onRetake,
              icon: const Icon(Icons.replay_rounded),
              label: Text(l10n.text('examTestRetake')),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSizes.spacing16),
            Text(
              context.l10n.text('examTestDetailLoadFailed'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacing16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.text('retry')),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDuration(Duration d) {
  final totalSeconds = d.inSeconds < 0 ? 0 : d.inSeconds;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return hours > 0
      ? '$hours:${two(minutes)}:${two(seconds)}'
      : '${two(minutes)}:${two(seconds)}';
}

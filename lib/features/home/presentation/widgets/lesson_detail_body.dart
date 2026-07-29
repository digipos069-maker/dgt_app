import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/widgets/mixed_latex_text.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../theme/app_colors.dart';
import '../../application/lesson_controller.dart';
import '../../application/quiz_controller.dart';
import '../../application/tutorial_controller.dart';
import '../../domain/models/lesson_model.dart';
import '../../domain/models/quiz_submission_result.dart';
import '../pages/lesson_list_page.dart';
import 'lesson_detail_skeleton.dart';

class LessonDetailBody extends ConsumerWidget {
  const LessonDetailBody({
    required this.courseId,
    required this.lessonId,
    this.slug,
    this.onBack,
    super.key,
  });

  final String courseId;
  final String lessonId;
  final String? slug;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final battambangTheme = GoogleFonts.battambangTextTheme(
      theme.textTheme,
    ).apply(fontSizeDelta: 3);
    final tutorialSlug = slug?.trim() ?? '';
    final detailState = tutorialSlug.isNotEmpty
        ? ref.watch(
            tutorialDetailProvider(
              TutorialDetailRequest(courseId: courseId, slug: tutorialSlug),
            ),
          )
        : ref.watch(
            lessonDetailProvider(
              LessonDetailRequest(courseId: courseId, lessonId: lessonId),
            ),
          );

    return Theme(
      data: theme.copyWith(textTheme: battambangTheme),
      child: detailState.when(
        data: (detail) => LessonDetailContent(detail: detail, onBack: onBack),
        error: (_, _) => Center(child: Text(context.l10n.text('authFailed'))),
        loading: () => const LessonDetailSkeleton(),
      ),
    );
  }
}

class LessonDetailContent extends ConsumerStatefulWidget {
  const LessonDetailContent({required this.detail, this.onBack, super.key});

  final LessonDetailModel detail;
  final VoidCallback? onBack;

  @override
  ConsumerState<LessonDetailContent> createState() =>
      _LessonDetailContentState();
}

class _LessonDetailContentState extends ConsumerState<LessonDetailContent> {
  final Map<String, String> _answers = {};
  final Set<String> _submittingQuestions = {};
  final Set<String> _submittedQuestions = {};
  final Map<String, _QuizAnswerFeedback> _answerFeedback = {};

  Future<void> _submitQuestion(QuizQuestionModel question) async {
    final selectedOptionId = _answers[question.id];
    if (selectedOptionId == null) {
      _showQuizSnackBar(context.l10n.text('quizSelectAnswer'));
      return;
    }

    final quizId = int.tryParse(question.id);
    if (quizId == null) {
      _showQuizSnackBar(
        context.l10n.text('quizSubmissionUnavailable'),
        isError: true,
      );
      return;
    }

    final selectedOption = question.options.firstWhere(
      (option) => option.id == selectedOptionId,
    );
    final genericFailureMessage = context.l10n.text('quizSubmitFailedMessage');
    setState(() => _submittingQuestions.add(question.id));

    QuizSubmissionResult? result;
    String? errorMessage;
    try {
      result = await ref
          .read(quizSubmissionControllerProvider)
          .submitAnswer(
            quizId: quizId,
            selectedAnswer: selectedOption.labelKey,
          );
    } on AppException catch (error) {
      errorMessage = error.message;
    } on Object {
      errorMessage = genericFailureMessage;
    } finally {
      if (mounted) {
        setState(() => _submittingQuestions.remove(question.id));
      }
    }

    if (!mounted) return;
    if (result == null) {
      _showQuizSnackBar(
        errorMessage?.isNotEmpty == true
            ? errorMessage!
            : context.l10n.text('quizSubmitFailedMessage'),
        isError: true,
      );
      return;
    }

    final isCorrect = result.isCorrect;
    final isIncorrect = isCorrect == false;
    final correctOptionId = _findCorrectOptionId(
      question,
      result.correctAnswer,
    );
    setState(() {
      if (!isIncorrect) {
        _submittedQuestions.add(question.id);
      }
      if (isCorrect != null) {
        _answerFeedback[question.id] = _QuizAnswerFeedback(
          isCorrect: isCorrect,
          selectedOptionId: selectedOptionId,
          correctOptionId: isCorrect ? selectedOptionId : correctOptionId,
        );
      }
    });
  }

  String? _findCorrectOptionId(
    QuizQuestionModel question,
    String correctAnswer,
  ) {
    if (correctAnswer.isEmpty) return null;
    final normalizedCorrectAnswer = _normalizeAnswer(correctAnswer);
    for (final option in question.options) {
      if (_normalizeAnswer(option.labelKey) == normalizedCorrectAnswer) {
        return option.id;
      }
    }
    return null;
  }

  String _normalizeAnswer(String answer) {
    return answer.trim().replaceAll(RegExp(r'\s+'), '');
  }

  void _showQuizSnackBar(String message, {bool isError = false}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? theme.colorScheme.error : null,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: _DetailHeader(detail: widget.detail, onBack: widget.onBack),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                0,
                AppSizes.spacing16,
                0,
                AppSizes.pageBottomPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 896),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _VideoSection(detail: widget.detail),
                      const SizedBox(height: AppSizes.spacing32),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.spacing4,
                        ),
                        child: _QuizSection(
                          detail: widget.detail,
                          answers: _answers,
                          onChanged: (questionId, optionId) {
                            setState(() {
                              _answers[questionId] = optionId;
                              _submittedQuestions.remove(questionId);
                              _answerFeedback.remove(questionId);
                            });
                          },
                          submittingQuestions: _submittingQuestions,
                          submittedQuestions: _submittedQuestions,
                          answerFeedback: _answerFeedback,
                          onSubmit: _submitQuestion,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.detail, this.onBack});

  final LessonDetailModel detail;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.92),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.30),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing16,
        vertical: AppSizes.spacing8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed:
                onBack ??
                () => context.goNamed(
                  LessonListPage.routeName,
                  pathParameters: {'courseId': detail.courseId},
                ),
            icon: const Icon(Icons.arrow_back),
          ),
          Expanded(
            child: Text(
              context.l10n.text(detail.titleKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
        ],
      ),
    );
  }
}

class _VideoSection extends StatefulWidget {
  const _VideoSection({required this.detail});

  final LessonDetailModel detail;

  @override
  State<_VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<_VideoSection> {
  VideoPlayerController? _controller;
  Timer? _controlsTimer;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant _VideoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detail.mainVideoUrl != widget.detail.mainVideoUrl) {
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    final previousController = _controller;
    _controller = null;
    await previousController?.dispose();

    final videoUrl = widget.detail.mainVideoUrl.trim();
    final uri = Uri.tryParse(videoUrl);
    if (uri == null || !uri.hasScheme) {
      if (mounted) setState(() {});
      return;
    }

    final controller = VideoPlayerController.networkUrl(
      uri,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
    );
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setVolume(1);
    } on Object {
      await controller.dispose();
      if (identical(_controller, controller)) {
        _controller = null;
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      await controller.pause();
      _showControlsPermanently();
    } else {
      await controller.play();
      _showControlsTemporarily();
    }
  }

  void _toggleControls() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (!controller.value.isPlaying) {
      _showControlsPermanently();
      return;
    }

    if (_showControls) {
      _controlsTimer?.cancel();
      setState(() => _showControls = false);
    } else {
      _showControlsTemporarily();
    }
  }

  void _showControlsTemporarily() {
    _controlsTimer?.cancel();
    if (mounted) setState(() => _showControls = true);
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller?.value.isPlaying == true) {
        setState(() => _showControls = false);
      }
    });
  }

  void _showControlsPermanently() {
    _controlsTimer?.cancel();
    if (mounted) setState(() => _showControls = true);
  }

  void _toggleMute() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    controller.setVolume(controller.value.volume == 0 ? 1 : 0);
  }

  void _openFullscreen() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _FullscreenVideoPage(controller: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = widget.detail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: _controller ?? _emptyVideoValue,
              builder: (context, value, _) {
                final isReady =
                    _controller != null &&
                    value.isInitialized &&
                    !value.hasError;
                final duration = isReady
                    ? _formatDuration(value.duration)
                    : detail.durationLabel;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    if (isReady)
                      VideoPlayer(_controller!)
                    else
                      _VideoArtwork(thumbnailUrl: detail.videoThumbnail),
                    Container(color: Colors.black.withValues(alpha: 0.06)),
                    if (isReady)
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _toggleControls,
                        ),
                      ),
                    IgnorePointer(
                      ignoring: isReady && !_showControls && value.isPlaying,
                      child: AnimatedOpacity(
                        opacity: !isReady || _showControls || !value.isPlaying
                            ? 1
                            : 0,
                        duration: const Duration(milliseconds: 220),
                        child: Center(
                          child: _PlayButton(
                            isPlaying: isReady && value.isPlaying,
                            onPressed: isReady ? _togglePlayback : null,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: AppSizes.spacing12,
                      right: AppSizes.spacing12,
                      bottom: AppSizes.spacing8,
                      child: IgnorePointer(
                        ignoring: isReady && !_showControls && value.isPlaying,
                        child: AnimatedOpacity(
                          opacity: !isReady || _showControls || !value.isPlaying
                              ? 1
                              : 0,
                          duration: const Duration(milliseconds: 220),
                          child: _VideoScrubber(
                            controller: isReady ? _controller : null,
                            duration: duration,
                            onToggleMute: isReady ? _toggleMute : null,
                            onFullscreen: isReady ? _openFullscreen : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizes.spacing16),
              Wrap(
                spacing: AppSizes.spacing8,
                runSpacing: AppSizes.spacing8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      context.l10n.text(detail.subjectKey),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    context.l10n.text(detail.moduleKey),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacing8),
              Text(
                context.l10n.text(detail.titleKey),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSizes.spacing8),
              Text(
                context.l10n.text(detail.descriptionKey),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static final _emptyVideoValue = ValueNotifier<VideoPlayerValue>(
    VideoPlayerValue(duration: Duration.zero),
  );

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours == 0) return '$minutes:$seconds';
    return '${duration.inHours}:$minutes:$seconds';
  }
}

class _QuizSection extends StatelessWidget {
  const _QuizSection({
    required this.detail,
    required this.answers,
    required this.onChanged,
    required this.submittingQuestions,
    required this.submittedQuestions,
    required this.answerFeedback,
    required this.onSubmit,
  });

  final LessonDetailModel detail;
  final Map<String, String> answers;
  final void Function(String questionId, String optionId) onChanged;
  final Set<String> submittingQuestions;
  final Set<String> submittedQuestions;
  final Map<String, _QuizAnswerFeedback> answerFeedback;
  final ValueChanged<QuizQuestionModel> onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.quiz_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.text(detail.quizTitleKey),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing4),
                    Text(
                      context.l10n.text(detail.quizSubtitleKey),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing24),
          for (final (index, question) in detail.questions.indexed) ...[
            if (index > 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.spacing24,
                ),
                child: Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.65,
                  ),
                ),
              ),
            _QuizQuestion(
              number: index + 1,
              question: question,
              selectedOption: answers[question.id],
              onChanged: (optionId) => onChanged(question.id, optionId),
              isSubmitting: submittingQuestions.contains(question.id),
              isSubmitted: submittedQuestions.contains(question.id),
              feedback: answerFeedback[question.id],
              onSubmit: () => onSubmit(question),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuizQuestion extends StatelessWidget {
  const _QuizQuestion({
    required this.number,
    required this.question,
    required this.selectedOption,
    required this.onChanged,
    required this.isSubmitting,
    required this.isSubmitted,
    required this.feedback,
    required this.onSubmit,
  });

  final int number;
  final QuizQuestionModel question;
  final String? selectedOption;
  final ValueChanged<String> onChanged;
  final bool isSubmitting;
  final bool isSubmitted;
  final _QuizAnswerFeedback? feedback;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MixedLatexText(
          text: context.l10n.text(question.questionKey),
          prefix: '${context.l10n.text('questionPrefix')}$number. ',
          prefixStyle: TextStyle(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w900,
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSizes.spacing16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 620;
            return GridView.count(
              crossAxisCount: isWide ? 2 : 1,
              crossAxisSpacing: AppSizes.spacing12,
              mainAxisSpacing: AppSizes.spacing12,
              mainAxisExtent: 78,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final option in question.options)
                  _QuizOption(
                    option: option,
                    isSelected: selectedOption == option.id,
                    status: _statusForOption(option.id),
                    onTap: () => onChanged(option.id),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSizes.spacing16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: isSubmitting ? null : onSubmit,
            icon: isSubmitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    isSubmitted
                        ? Icons.check_circle_outline
                        : Icons.send_outlined,
                  ),
            label: Text(
              context.l10n.text(isSubmitted ? 'quizSubmitted' : 'submitQuiz'),
            ),
          ),
        ),
      ],
    );
  }

  _QuizOptionStatus _statusForOption(String optionId) {
    final currentFeedback = feedback;
    if (currentFeedback == null) return _QuizOptionStatus.neutral;
    if (currentFeedback.correctOptionId == optionId ||
        (currentFeedback.isCorrect &&
            currentFeedback.selectedOptionId == optionId)) {
      return _QuizOptionStatus.correct;
    }
    if (!currentFeedback.isCorrect &&
        currentFeedback.selectedOptionId == optionId) {
      return _QuizOptionStatus.incorrect;
    }
    return _QuizOptionStatus.neutral;
  }
}

class _QuizOption extends StatelessWidget {
  const _QuizOption({
    required this.option,
    required this.isSelected,
    required this.status,
    required this.onTap,
  });

  final QuizOptionModel option;
  final bool isSelected;
  final _QuizOptionStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = switch (status) {
      _QuizOptionStatus.correct => AppColors.success,
      _QuizOptionStatus.incorrect => AppColors.error,
      _QuizOptionStatus.neutral => null,
    };
    final backgroundColor = switch (status) {
      _QuizOptionStatus.correct => AppColors.success.withValues(alpha: 0.06),
      _QuizOptionStatus.incorrect => AppColors.error.withValues(alpha: 0.06),
      _QuizOptionStatus.neutral =>
        isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.07)
            : theme.colorScheme.surface,
    };

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color:
                  statusColor ??
                  (isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant),
              width: status == _QuizOptionStatus.neutral && !isSelected
                  ? 1
                  : 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacing16,
            vertical: AppSizes.spacing12,
          ),
          child: Row(
            children: [
              _SelectionIndicator(isSelected: isSelected, status: status),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MixedLatexText(
                      text: context.l10n.text(option.labelKey),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    if (status != _QuizOptionStatus.neutral) ...[
                      const SizedBox(height: AppSizes.spacing4),
                      Text(
                        context.l10n.text(
                          status == _QuizOptionStatus.correct
                              ? 'quizAnswerCorrect'
                              : 'quizAnswerIncorrect',
                        ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.isSelected, required this.status});

  final bool isSelected;
  final _QuizOptionStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      _QuizOptionStatus.correct => AppColors.success,
      _QuizOptionStatus.incorrect => AppColors.error,
      _QuizOptionStatus.neutral => Theme.of(context).colorScheme.primary,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? color : Theme.of(context).colorScheme.outline,
          width: 1.5,
        ),
      ),
      child: status == _QuizOptionStatus.correct
          ? Icon(Icons.check, color: color, size: 14)
          : status == _QuizOptionStatus.incorrect
          ? Icon(Icons.close, color: color, size: 14)
          : isSelected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            )
          : null,
    );
  }
}

enum _QuizOptionStatus { neutral, correct, incorrect }

class _QuizAnswerFeedback {
  const _QuizAnswerFeedback({
    required this.isCorrect,
    required this.selectedOptionId,
    required this.correctOptionId,
  });

  final bool isCorrect;
  final String selectedOptionId;
  final String? correctOptionId;
}

class _VideoArtwork extends StatelessWidget {
  const _VideoArtwork({required this.thumbnailUrl});

  final String thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8EDFA), Color(0xFFE0F2FE)],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '2x + 5 = 15',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 37,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 24,
            child: Icon(Icons.edit_note, color: AppColors.secondary, size: 42),
          ),
        ],
      ),
    );
    if (thumbnailUrl.isEmpty) return fallback;
    return Image.network(
      thumbnailUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.isPlaying, required this.onPressed});

  final bool isPlaying;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.48),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: onPressed == null
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _VideoScrubber extends StatelessWidget {
  const _VideoScrubber({
    required this.controller,
    required this.duration,
    required this.onToggleMute,
    required this.onFullscreen,
    this.isFullscreen = false,
  });

  final VideoPlayerController? controller;
  final String duration;
  final VoidCallback? onToggleMute;
  final VoidCallback? onFullscreen;
  final bool isFullscreen;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        controller == null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: 0,
                  minHeight: 3,
                  backgroundColor: Colors.white.withValues(alpha: 0.35),
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : VideoProgressIndicator(
                controller!,
                allowScrubbing: true,
                padding: const EdgeInsets.symmetric(vertical: 5),
                colors: VideoProgressColors(
                  playedColor: Theme.of(context).colorScheme.primary,
                  bufferedColor: Colors.white.withValues(alpha: 0.55),
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                ),
              ),
        Row(
          children: [
            IconButton(
              tooltip: controller?.value.volume == 0
                  ? context.l10n.text('videoUnmute')
                  : context.l10n.text('videoMute'),
              onPressed: onToggleMute,
              color: Colors.white,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 36, height: 32),
              icon: Icon(
                controller?.value.volume == 0
                    ? Icons.volume_off
                    : Icons.volume_up,
                size: 19,
              ),
            ),
            const SizedBox(width: AppSizes.spacing4),
            Text(
              controller == null
                  ? '0:00'
                  : _formatPosition(controller!.value.position),
              style: textStyle,
            ),
            const SizedBox(width: AppSizes.spacing4),
            Text('/', style: textStyle),
            const SizedBox(width: AppSizes.spacing4),
            Text(duration, style: textStyle),
            const Spacer(),
            IconButton(
              tooltip: context.l10n.text(
                isFullscreen ? 'videoExitFullscreen' : 'videoFullscreen',
              ),
              onPressed: onFullscreen,
              color: Colors.white,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 36, height: 32),
              icon: Icon(
                isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                size: 22,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatPosition(Duration position) {
    final minutes = position.inMinutes.remainder(60);
    final seconds = position.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (position.inHours == 0) return '$minutes:$seconds';
    return '${position.inHours}:${minutes.toString().padLeft(2, '0')}:$seconds';
  }
}

class _FullscreenVideoPage extends StatefulWidget {
  const _FullscreenVideoPage({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<_FullscreenVideoPage> {
  Timer? _controlsTimer;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    if (widget.controller.value.isPlaying) {
      _showControlsTemporarily();
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (widget.controller.value.isPlaying) {
      await widget.controller.pause();
      _showControlsPermanently();
    } else {
      await widget.controller.play();
      _showControlsTemporarily();
    }
  }

  void _toggleControls() {
    if (!widget.controller.value.isPlaying) {
      _showControlsPermanently();
      return;
    }

    if (_showControls) {
      _controlsTimer?.cancel();
      setState(() => _showControls = false);
    } else {
      _showControlsTemporarily();
    }
  }

  void _showControlsTemporarily() {
    _controlsTimer?.cancel();
    if (mounted) setState(() => _showControls = true);
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _showControlsPermanently() {
    _controlsTimer?.cancel();
    if (mounted) setState(() => _showControls = true);
  }

  void _toggleMute() {
    widget.controller.setVolume(widget.controller.value.volume == 0 ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: widget.controller,
        builder: (context, value, _) {
          final duration = _formatVideoDuration(value.duration);

          return Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: value.aspectRatio > 0
                      ? value.aspectRatio
                      : 16 / 9,
                  child: VideoPlayer(widget.controller),
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _toggleControls,
                ),
              ),
              IgnorePointer(
                ignoring: !_showControls && value.isPlaying,
                child: AnimatedOpacity(
                  opacity: _showControls || !value.isPlaying ? 1 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: Center(
                    child: _PlayButton(
                      isPlaying: value.isPlaying,
                      onPressed: _togglePlayback,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: AppSizes.spacing12,
                right: AppSizes.spacing12,
                bottom: AppSizes.spacing8,
                child: IgnorePointer(
                  ignoring: !_showControls && value.isPlaying,
                  child: AnimatedOpacity(
                    opacity: _showControls || !value.isPlaying ? 1 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: _VideoScrubber(
                      controller: widget.controller,
                      duration: duration,
                      onToggleMute: _toggleMute,
                      onFullscreen: () => Navigator.of(context).pop(),
                      isFullscreen: true,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _formatVideoDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (duration.inHours == 0) return '$minutes:$seconds';
  return '${duration.inHours}:$minutes:$seconds';
}

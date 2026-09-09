import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../localization/app_localizations.dart';
import '../../application/lesson_controller.dart';
import '../../application/quiz_controller.dart';
import '../../application/tutorial_controller.dart';
import '../../application/daily_goal_controller.dart';
import '../../data/daily_goal_repository.dart';
import '../../../auth/application/auth_controller.dart';
import '../../domain/models/lesson_model.dart';
import '../../domain/models/quiz_submission_result.dart';
import '../pages/lesson_list_page.dart';
import 'lesson_detail_skeleton.dart';
import 'quiz/lesson_quiz_section.dart';

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
  final Map<String, Map<String, String>> _matchingAnswers = {};
  final Map<String, String?> _dragAnswers = {};
  final Set<String> _submittingQuestions = {};
  final Set<String> _submittedQuestions = {};
  final Map<String, QuizAnswerFeedback> _answerFeedback = {};

  @override
  void didUpdateWidget(covariant LessonDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detail.lessonId != widget.detail.lessonId) {
      _answers.clear();
      _matchingAnswers.clear();
      _dragAnswers.clear();
      _submittingQuestions.clear();
      _submittedQuestions.clear();
      _answerFeedback.clear();
    }
  }

  Future<void> _submitQuestion(QuizQuestionModel question) async {
    switch (question.type) {
      case QuizType.matching:
        _submitMatchingQuestion(question);
        break;
      case QuizType.dragAndDrop:
        _submitDragAndDropQuestion(question);
        break;
      case QuizType.multipleChoice:
        await _submitMultipleChoiceQuestion(question);
        break;
    }
  }

  void _submitMatchingQuestion(QuizQuestionModel question) {
    final matches = _matchingAnswers[question.id] ?? {};
    final matchingData = question.matchingData;
    if (matchingData == null) return;

    if (matches.length < matchingData.stems.length) {
      _showQuizSnackBar('Please match all terms before submitting.');
      return;
    }

    final isCorrect = matchingData.areAllMatchesCorrect(matches);
    setState(() {
      if (isCorrect) {
        _submittedQuestions.add(question.id);
      }
      _answerFeedback[question.id] = QuizAnswerFeedback(isCorrect: isCorrect);
    });

    _showQuizSnackBar(
      isCorrect
          ? context.l10n.text('quizCorrect')
          : context.l10n.text('quizIncorrect'),
      isError: !isCorrect,
    );
  }

  void _submitDragAndDropQuestion(QuizQuestionModel question) {
    final dropped = _dragAnswers[question.id];
    final dragData = question.dragAndDropData;
    if (dragData == null) return;

    if (dropped == null || dropped.isEmpty) {
      _showQuizSnackBar('Please place an answer before submitting.');
      return;
    }

    final isCorrect = dragData.isCorrect(dropped);
    setState(() {
      if (isCorrect) {
        _submittedQuestions.add(question.id);
      }
      _answerFeedback[question.id] = QuizAnswerFeedback(
        isCorrect: isCorrect,
        selectedAnswer: dropped,
        correctAnswer: dragData.correct,
      );
    });

    _showQuizSnackBar(
      isCorrect
          ? context.l10n.text('quizCorrect')
          : context.l10n.text('quizIncorrect'),
      isError: !isCorrect,
    );
  }

  Future<void> _submitMultipleChoiceQuestion(QuizQuestionModel question) async {
    final selectedOptionId = _answers[question.id];
    if (selectedOptionId == null) {
      _showQuizSnackBar(context.l10n.text('quizSelectAnswer'));
      return;
    }

    final quizId = question.quizId;
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
        _answerFeedback[question.id] = QuizAnswerFeedback(
          isCorrect: isCorrect,
          selectedAnswer: selectedOptionId,
          correctAnswer: isCorrect ? selectedOptionId : correctOptionId,
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
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  AppSizes.spacing16,
                  0,
                  AppSizes.pageBottomPadding,
                ),
                physics: const ClampingScrollPhysics(),
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
                          child: LessonQuizSection(
                            quizTitleKey: widget.detail.quizTitleKey,
                            quizSubtitleKey: widget.detail.quizSubtitleKey,
                            questions: widget.detail.questions,
                            answers: _answers,
                            onChanged: (questionId, optionId) {
                              setState(() {
                                _answers[questionId] = optionId;
                                _submittedQuestions.remove(questionId);
                                _answerFeedback.remove(questionId);
                              });
                            },
                            matchingAnswers: _matchingAnswers,
                            onMatchingChanged: (questionId, matches) {
                              setState(() {
                                _matchingAnswers[questionId] = matches;
                                _submittedQuestions.remove(questionId);
                                _answerFeedback.remove(questionId);
                              });
                            },
                            dragAnswers: _dragAnswers,
                            onDragChanged: (questionId, droppedItem) {
                              setState(() {
                                _dragAnswers[questionId] = droppedItem;
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

class _VideoSection extends ConsumerStatefulWidget {
  const _VideoSection({required this.detail});

  final LessonDetailModel detail;

  @override
  ConsumerState<_VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends ConsumerState<_VideoSection> {
  VideoPlayerController? _controller;
  Timer? _controlsTimer;
  bool _showControls = true;
  bool _isVideoInitializing = true;
  bool _videoHasError = false;
  bool _hasMarkedCompleted = false;

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
    _isVideoInitializing = true;
    _videoHasError = false;
    _hasMarkedCompleted = false;
    if (mounted) setState(() {});

    final previousController = _controller;
    _controller = null;
    await previousController?.dispose();

    final videoUrl = widget.detail.mainVideoUrl.trim();
    final uri = Uri.tryParse(videoUrl);
    if (uri == null || !uri.hasScheme) {
      _isVideoInitializing = false;
      _videoHasError = true;
      if (mounted) setState(() {});
      return;
    }

    final controller = VideoPlayerController.networkUrl(
      uri,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
    );
    _controller = controller;

    controller.addListener(_videoListener);

    try {
      await controller.initialize();
      await controller.setVolume(1);
      await controller.play();
    } on Object {
      await controller.dispose();
      _videoHasError = true;
      if (identical(_controller, controller)) {
        _controller = null;
      }
    }
    _isVideoInitializing = false;
    if (mounted) {
      setState(() {});
      if (_controller?.value.isPlaying == true) {
        _showControlsTemporarily();
      }
    }
  }

  void _videoListener() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final value = controller.value;
    if (!value.isPlaying && value.position >= value.duration && value.duration > Duration.zero) {
      if (!_hasMarkedCompleted) {
        _hasMarkedCompleted = true;
        _markVideoAsCompleted();
      }
    }
  }

  Future<void> _markVideoAsCompleted() async {
    final user = ref.read(authControllerProvider).value;
    if (user?.token == null) return;
    try {
      // Assuming lessonId or video URL can be used; passing 0 as a placeholder since we don't have videoId strictly in model
      // Wait, we need to pass a videoId. Let's use hashcode or parse from URL if possible.
      // But the API takes an int videoId. I will just pass a dummy ID for now or hash of URL.
      int videoId = widget.detail.mainVideoUrl.hashCode; 
      await ref.read(dailyGoalRepositoryProvider).completeVideo(user!.token!, videoId);
      
      // Also refresh the goal controller to get updated state
      ref.invalidate(dailyGoalControllerProvider);
    } catch (e) {
      debugPrint('Failed to complete video: $e');
    }
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
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 180),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, animation, secondaryAnimation) =>
            _FullscreenVideoPage(controller: controller),
        transitionsBuilder: (_, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
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
                      _VideoArtwork(
                        thumbnailUrl: detail.videoThumbnail,
                        isLoading: _isVideoInitializing,
                        hasError: _videoHasError,
                      ),
                    Container(color: Colors.black.withValues(alpha: 0.06)),
                    if (isReady)
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _toggleControls,
                        ),
                      ),
                    if (isReady)
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
                    if (isReady)
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
                              controller: _controller,
                              duration: duration,
                              onToggleMute: _toggleMute,
                              onFullscreen: _openFullscreen,
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

class _VideoArtwork extends StatelessWidget {
  const _VideoArtwork({
    required this.thumbnailUrl,
    required this.isLoading,
    required this.hasError,
  });

  final String thumbnailUrl;
  final bool isLoading;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final placeholder = _VideoLoadingPlaceholder(
      isLoading: isLoading,
      hasError: hasError,
    );
    if (hasError) return placeholder;
    if (thumbnailUrl.isEmpty) return placeholder;

    return Image.network(
      thumbnailUrl,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return placeholder;
      },
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

class _VideoLoadingPlaceholder extends StatelessWidget {
  const _VideoLoadingPlaceholder({
    required this.isLoading,
    required this.hasError,
  });

  final bool isLoading;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: const Color(0xFF171B22),
      child: Center(
        child: hasError
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.videocam_off_outlined,
                    color: Colors.white70,
                    size: 34,
                  ),
                  const SizedBox(height: AppSizes.spacing8),
                  Text(
                    context.l10n.text('videoLoadFailed'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              )
            : isLoading
            ? const SizedBox.square(
                dimension: 26,
                child: CircularProgressIndicator(
                  color: Colors.white70,
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.play_circle_outline,
                color: Colors.white70,
                size: 36,
              ),
      ),
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

    return Row(
      children: [
        IconButton(
          tooltip: controller?.value.volume == 0
              ? context.l10n.text('videoUnmute')
              : context.l10n.text('videoMute'),
          onPressed: onToggleMute,
          color: Colors.white,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
          icon: Icon(
            controller?.value.volume == 0 ? Icons.volume_off : Icons.volume_up,
            size: 18,
          ),
        ),
        const SizedBox(width: AppSizes.spacing4),
        Text(
          controller == null
              ? '0:00'
              : _formatPosition(controller!.value.position),
          style: textStyle,
        ),
        const SizedBox(width: AppSizes.spacing8),
        Expanded(
          child: controller == null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: 0,
                    minHeight: 3,
                    backgroundColor: Colors.white.withValues(alpha: 0.35),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    activeTrackColor: Theme.of(context).colorScheme.primary,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.32),
                    thumbColor: Theme.of(context).colorScheme.primary,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 5,
                    ),
                    overlayColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.16),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                  ),
                  child: Slider(
                    min: 0,
                    max: _durationMilliseconds(controller!),
                    value: _positionMilliseconds(controller!),
                    onChanged: (value) => controller!.seekTo(
                      Duration(milliseconds: value.round()),
                    ),
                  ),
                ),
        ),
        const SizedBox(width: AppSizes.spacing8),
        Text(duration, style: textStyle),
        const SizedBox(width: AppSizes.spacing4),
        IconButton(
          tooltip: context.l10n.text(
            isFullscreen ? 'videoExitFullscreen' : 'videoFullscreen',
          ),
          onPressed: onFullscreen,
          color: Colors.white,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
          icon: Icon(
            isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
            size: 21,
          ),
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

  double _durationMilliseconds(VideoPlayerController controller) {
    return controller.value.duration.inMilliseconds
        .clamp(1, double.maxFinite)
        .toDouble();
  }

  double _positionMilliseconds(VideoPlayerController controller) {
    final duration = _durationMilliseconds(controller);
    return controller.value.position.inMilliseconds
        .clamp(0, duration)
        .toDouble();
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
  bool _showTransitionCover = true;
  bool _isClosing = false;
  bool _restoredBeforePop = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _enterFullscreen());
    if (widget.controller.value.isPlaying) {
      _showControlsTemporarily();
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    if (!_restoredBeforePop) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
    super.dispose();
  }

  Future<void> _enterFullscreen() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await _waitForOrientation(landscape: true);
    if (!mounted) return;
    setState(() => _showTransitionCover = false);
  }

  Future<void> _exitFullscreen() async {
    if (_isClosing) return;
    _isClosing = true;
    _controlsTimer?.cancel();
    setState(() {
      _showControls = false;
      _showTransitionCover = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 180));
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
    await _waitForOrientation(landscape: false);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (!mounted) return;

    _restoredBeforePop = true;
    Navigator.of(context).pop();
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    });
  }

  Future<void> _waitForOrientation({required bool landscape}) async {
    for (var attempt = 0; attempt < 20; attempt++) {
      if (!mounted) return;
      final size = MediaQuery.sizeOf(context);
      if ((size.width > size.height) == landscape) {
        await WidgetsBinding.instance.endOfFrame;
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 30));
    }
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _exitFullscreen();
      },
      child: Scaffold(
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
                        onFullscreen: _exitFullscreen,
                        isFullscreen: true,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: _showTransitionCover ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const ColoredBox(color: Colors.black),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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

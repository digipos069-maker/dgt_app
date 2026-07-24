import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
        loading: () => const Center(child: CircularProgressIndicator()),
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

  Future<void> _submitQuestion(QuizQuestionModel question) async {
    final selectedOptionId = _answers[question.id];
    if (selectedOptionId == null) {
      await _showQuizDialog(
        icon: Icons.touch_app_outlined,
        color: Theme.of(context).colorScheme.primary,
        title: context.l10n.text('submitQuiz'),
        message: context.l10n.text('quizSelectAnswer'),
      );
      return;
    }

    final quizId = int.tryParse(question.id);
    if (quizId == null) {
      await _showQuizDialog(
        icon: Icons.info_outline,
        color: Theme.of(context).colorScheme.secondary,
        title: context.l10n.text('quizSubmitFailed'),
        message: context.l10n.text('quizSubmissionUnavailable'),
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
      await _showQuizDialog(
        icon: Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
        title: context.l10n.text('quizSubmitFailed'),
        message: errorMessage?.isNotEmpty == true
            ? errorMessage!
            : context.l10n.text('quizSubmitFailedMessage'),
      );
      return;
    }

    final isIncorrect = result.isCorrect == false;
    if (!isIncorrect) {
      setState(() => _submittedQuestions.add(question.id));
    }
    await _showQuizDialog(
      icon: isIncorrect ? Icons.refresh : Icons.check_circle_outline,
      color: isIncorrect ? Colors.orange.shade700 : AppColors.success,
      title: context.l10n.text(isIncorrect ? 'quizTryAgain' : 'quizSubmitted'),
      message: result.message.isNotEmpty
          ? result.message
          : context.l10n.text(isIncorrect ? 'quizIncorrect' : 'quizCorrect'),
    );
  }

  Future<void> _showQuizDialog({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(icon, color: color, size: 44),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.text('close')),
          ),
        ],
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
                10,
                AppSizes.spacing16,
                10,
                128,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 896),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _VideoSection(detail: widget.detail),
                      const SizedBox(height: AppSizes.spacing32),
                      _QuizSection(
                        detail: widget.detail,
                        answers: _answers,
                        onChanged: (questionId, optionId) {
                          setState(() {
                            _answers[questionId] = optionId;
                            _submittedQuestions.remove(questionId);
                          });
                        },
                        submittingQuestions: _submittingQuestions,
                        submittedQuestions: _submittedQuestions,
                        onSubmit: _submitQuestion,
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

    final controller = VideoPlayerController.networkUrl(uri);
    _controller = controller;
    try {
      await controller.initialize();
    } on Object {
      await controller.dispose();
      if (identical(_controller, controller)) {
        _controller = null;
      }
    }
    if (mounted) setState(() {});
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
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
                    Container(color: Colors.black.withValues(alpha: 0.20)),
                    Positioned(
                      top: AppSizes.spacing16,
                      right: AppSizes.spacing16,
                      child: _DurationBadge(duration: duration),
                    ),
                    Center(
                      child: _PlayButton(
                        isPlaying: isReady && value.isPlaying,
                        onPressed: isReady ? _togglePlayback : null,
                      ),
                    ),
                    Positioned(
                      left: AppSizes.spacing16,
                      right: AppSizes.spacing16,
                      bottom: AppSizes.spacing16,
                      child: _VideoScrubber(
                        controller: isReady ? _controller : null,
                        duration: duration,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spacing16),
        Wrap(
          spacing: AppSizes.spacing8,
          runSpacing: AppSizes.spacing8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    required this.onSubmit,
  });

  final LessonDetailModel detail;
  final Map<String, String> answers;
  final void Function(String questionId, String optionId) onChanged;
  final Set<String> submittingQuestions;
  final Set<String> submittedQuestions;
  final ValueChanged<QuizQuestionModel> onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSizes.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.quiz, color: theme.colorScheme.secondary),
              ),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.text(detail.quizTitleKey),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing4),
                    Text(
                      context.l10n.text(detail.quizSubtitleKey),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 32, color: theme.colorScheme.surfaceContainerHighest),
          for (final (index, question) in detail.questions.indexed) ...[
            _QuizQuestion(
              number: index + 1,
              question: question,
              selectedOption: answers[question.id],
              onChanged: (optionId) => onChanged(question.id, optionId),
              isSubmitting: submittingQuestions.contains(question.id),
              isSubmitted: submittedQuestions.contains(question.id),
              onSubmit: () => onSubmit(question),
            ),
            const SizedBox(height: AppSizes.spacing24),
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
    required this.onSubmit,
  });

  final int number;
  final QuizQuestionModel question;
  final String? selectedOption;
  final ValueChanged<String> onChanged;
  final bool isSubmitting;
  final bool isSubmitted;
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
              childAspectRatio: isWide ? 5.8 : 5.2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final option in question.options)
                  _QuizOption(
                    option: option,
                    isSelected: selectedOption == option.id,
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
}

class _QuizOption extends StatelessWidget {
  const _QuizOption({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final QuizOptionModel option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
        ),
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: Row(
          children: [
            _SelectionIndicator(isSelected: isSelected),
            const SizedBox(width: AppSizes.spacing8),
            Expanded(
              child: MixedLatexText(
                text: context.l10n.text(option.labelKey),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? color : Theme.of(context).colorScheme.outline,
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            )
          : null,
    );
  }
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

class _DurationBadge extends StatelessWidget {
  const _DurationBadge({required this.duration});

  final String duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        duration,
        style: const TextStyle(fontWeight: FontWeight.w900),
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
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 6,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 64,
          height: 64,
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: onPressed == null
                ? AppColors.secondary.withValues(alpha: 0.55)
                : AppColors.secondary,
            size: 36,
          ),
        ),
      ),
    );
  }
}

class _VideoScrubber extends StatelessWidget {
  const _VideoScrubber({required this.controller, required this.duration});

  final VideoPlayerController? controller;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            controller == null
                ? '0:00'
                : _formatPosition(controller!.value.position),
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(width: AppSizes.spacing12),
          Expanded(
            child: controller == null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: 0,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.35),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : VideoProgressIndicator(
                    controller!,
                    allowScrubbing: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    colors: VideoProgressColors(
                      playedColor: Theme.of(context).colorScheme.primary,
                      bufferedColor: Colors.white.withValues(alpha: 0.55),
                      backgroundColor: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
          ),
          const SizedBox(width: AppSizes.spacing12),
          Text(duration, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: AppSizes.spacing8),
          const Icon(Icons.fullscreen, size: 18),
        ],
      ),
    );
  }

  String _formatPosition(Duration position) {
    final minutes = position.inMinutes.remainder(60);
    final seconds = position.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (position.inHours == 0) return '$minutes:$seconds';
    return '${position.inHours}:${minutes.toString().padLeft(2, '0')}:$seconds';
  }
}

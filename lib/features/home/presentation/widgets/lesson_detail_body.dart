import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/scroll_hiding_header.dart';
import '../../../../localization/app_localizations.dart';
import '../../application/lesson_controller.dart';
import '../../domain/models/lesson_model.dart';
import '../pages/lesson_list_page.dart';

class LessonDetailBody extends ConsumerWidget {
  const LessonDetailBody({
    required this.courseId,
    required this.lessonId,
    super.key,
  });

  final String courseId;
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final battambangTheme = GoogleFonts.battambangTextTheme(theme.textTheme);
    final detailState = ref.watch(
      lessonDetailProvider(
        LessonDetailRequest(courseId: courseId, lessonId: lessonId),
      ),
    );

    return Theme(
      data: theme.copyWith(textTheme: battambangTheme),
      child: detailState.when(
        data: (detail) => _LessonDetailContent(detail: detail),
        error: (_, _) => Center(child: Text(context.l10n.text('authFailed'))),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _LessonDetailContent extends StatefulWidget {
  const _LessonDetailContent({required this.detail});

  final LessonDetailModel detail;

  @override
  State<_LessonDetailContent> createState() => _LessonDetailContentState();
}

class _LessonDetailContentState extends State<_LessonDetailContent> {
  final Map<String, String> _answers = {};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ScrollHidingHeader(
        header: _DetailHeader(detail: widget.detail),
        headerHeight: 56,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10, AppSizes.spacing16, 10, 128),
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
                      setState(() => _answers[questionId] = optionId);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.detail});

  final LessonDetailModel detail;

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
            onPressed: () => context.goNamed(
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
                color: theme.colorScheme.primary,
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

class _VideoSection extends StatelessWidget {
  const _VideoSection({required this.detail});

  final LessonDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            child: Stack(
              fit: StackFit.expand,
              children: [
                const _VideoArtwork(),
                Container(color: Colors.black.withValues(alpha: 0.20)),
                Positioned(
                  top: AppSizes.spacing16,
                  right: AppSizes.spacing16,
                  child: _DurationBadge(duration: detail.durationLabel),
                ),
                const Center(child: _PlayButton()),
                Positioned(
                  left: AppSizes.spacing16,
                  right: AppSizes.spacing16,
                  bottom: AppSizes.spacing16,
                  child: _MockScrubber(duration: detail.durationLabel),
                ),
              ],
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
                color: const Color(0xFFC0EDD0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                context.l10n.text(detail.subjectKey),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF264F39),
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
            color: theme.colorScheme.primary,
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
}

class _QuizSection extends StatelessWidget {
  const _QuizSection({
    required this.detail,
    required this.answers,
    required this.onChanged,
  });

  final LessonDetailModel detail;
  final Map<String, String> answers;
  final void Function(String questionId, String optionId) onChanged;

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
                decoration: const BoxDecoration(
                  color: Color(0xFFE8DDFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.quiz, color: Color(0xFF21005E)),
              ),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.text(detail.quizTitleKey),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
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
            ),
            const SizedBox(height: AppSizes.spacing24),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward),
              label: Text(context.l10n.text('submitQuiz')),
            ),
          ),
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
  });

  final int number;
  final QuizQuestionModel question;
  final String? selectedOption;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${context.l10n.text('questionPrefix')}$number. ',
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(text: context.l10n.text(question.questionKey)),
            ],
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
              ? const Color(0xFFE8DDFF)
              : theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.secondary
                : theme.colorScheme.outlineVariant,
          ),
        ),
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: Row(
          children: [
            _SelectionIndicator(isSelected: isSelected),
            const SizedBox(width: AppSizes.spacing8),
            Expanded(
              child: Text(
                context.l10n.text(option.labelKey),
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
    final color = Theme.of(context).colorScheme.secondary;

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
  const _VideoArtwork();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3E8FF), Color(0xFFE0F2FE)],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '2x + 5 = 15',
              style: TextStyle(
                color: Color(0xFF2D3142),
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 24,
            child: Icon(Icons.edit_note, color: Color(0xFF674BB5), size: 42),
          ),
        ],
      ),
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
  const _PlayButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.play_arrow, color: Color(0xFF674BB5), size: 36),
    );
  }
}

class _MockScrubber extends StatelessWidget {
  const _MockScrubber({required this.duration});

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
          const Text('0:00', style: TextStyle(fontSize: 12)),
          const SizedBox(width: AppSizes.spacing12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: 0,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.35),
                color: const Color(0xFF674BB5),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacing12),
          Text(duration, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: AppSizes.spacing8),
          const Icon(Icons.fullscreen, size: 18),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/scroll_hiding_header.dart';
import '../../../../localization/app_localizations.dart';
import '../../../home/presentation/widgets/main_bottom_navigation.dart';
import '../../application/auth_controller.dart';
import '../widgets/language_menu_button.dart';
import '../widgets/theme_toggle_button.dart';
import 'login_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const routeName = 'home';
  static const routePath = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final user = switch (ref.watch(authControllerProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };

    return ScrollHidingHeaderScaffold(
      headerHeight: 64,
      header: AppBar(
        toolbarHeight: 64,
        titleSpacing: AppSizes.spacing16,
        title: Row(
          children: [
            _StudentAvatar(imageUrl: user?.imageUrl, name: user?.username),
            const SizedBox(width: AppSizes.spacing12),
            Flexible(
              child: Text(
                'DGT',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        actions: [
          const LanguageMenuButton(),
          const ThemeToggleButton(),
          PopupMenuButton<String>(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(authControllerProvider.notifier).logout();
                context.goNamed(LoginPage.routeName);
              }
            },
            itemBuilder: (context) => [
              if (user != null)
                PopupMenuItem(enabled: false, child: Text(user.email)),
              PopupMenuItem(value: 'logout', child: Text(l10n.text('logout'))),
            ],
          ),
          const SizedBox(width: AppSizes.spacing8),
        ],
      ),
      body: _HomeDashboard(username: user?.username),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 0),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard({this.username});

  final String? username;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final battambangTheme = GoogleFonts.battambangTextTheme(theme.textTheme);

    return Theme(
      data: theme.copyWith(textTheme: battambangTheme),
      child: _HomeDashboardContent(username: username),
    );
  }
}

class _HomeDashboardContent extends StatelessWidget {
  const _HomeDashboardContent({this.username});

  final String? username;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 920;
    const horizontalPadding = 10.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        horizontalPadding,
        32,
        horizontalPadding,
        112,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SearchField(),
              const SizedBox(height: AppSizes.spacing24),
              _WelcomeSummary(username: username),
              const SizedBox(height: AppSizes.spacing24),
              if (isWide)
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 8, child: _LearningColumn()),
                    SizedBox(width: AppSizes.spacing32),
                    Expanded(flex: 4, child: _StatsColumn()),
                  ],
                )
              else
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LearningColumn(),
                    SizedBox(height: AppSizes.spacing32),
                    _StatsColumn(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningColumn extends StatelessWidget {
  const _LearningColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.text('homeContinueLearning'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSizes.spacing16),
        const _ContinueLearningCard(),
        const SizedBox(height: AppSizes.spacing32),
        Text(
          context.l10n.text('homePopularSubjects'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSizes.spacing16),
        const _SubjectGrid(),
        const SizedBox(height: AppSizes.spacing32),
        Text(
          context.l10n.text('homeRecommendedLessons'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSizes.spacing16),
        const _RecommendedLessons(),
      ],
    );
  }
}

class _StatsColumn extends StatelessWidget {
  const _StatsColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProgressStatsCard(),
        SizedBox(height: AppSizes.spacing32),
        _DailyGoalCard(),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: TextField(
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: context.l10n.text('homeSearchHint'),
            prefixIcon: const Icon(Icons.search),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacing16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeSummary extends StatelessWidget {
  const _WelcomeSummary({this.username});

  final String? username;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4EA),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFC0EDD0), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSizes.spacing24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.l10n.text('homeGreeting')} ${username ?? context.l10n.text('homeStudentDefault')}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF0F3925),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  context.l10n.text('homeTodayPlan'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF264F39),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spacing16),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFA4D1B4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.school, color: Color(0xFF0F3925), size: 38),
          ),
        ],
      ),
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard();

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 620;
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: const AspectRatio(aspectRatio: 16 / 10, child: _LessonArtwork()),
    );

    return Material(
      color: const Color(0xFFF3E8FF),
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: () {},
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFFCEBDFF), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppSizes.spacing24),
                child: isCompact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          image,
                          const SizedBox(height: AppSizes.spacing20),
                          const _ContinueLearningContent(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 240, child: image),
                          const SizedBox(width: AppSizes.spacing24),
                          const Expanded(child: _ContinueLearningContent()),
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

class _ContinueLearningContent extends StatelessWidget {
  const _ContinueLearningContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.text('homeContinueSubject'),
          style: theme.textTheme.labelMedium?.copyWith(
            color: _HomeColors.purple,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          context.l10n.text('homeContinueTitle'),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          context.l10n.text('homeContinueDescription'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSizes.spacing20),
        const _LinearProgressSummary(progress: 0.65),
      ],
    );
  }
}

class _LinearProgressSummary extends StatelessWidget {
  const _LinearProgressSummary({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.text('homeProgress'),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '$percent%',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 12,
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: _HomeColors.purple,
          ),
        ),
      ],
    );
  }
}

class _SubjectGrid extends StatelessWidget {
  const _SubjectGrid();

  static const _subjects = [
    _SubjectItem('homeSubjectMath', Icons.calculate, Color(0xFF2563EB)),
    _SubjectItem('homeSubjectChemistry', Icons.science, Color(0xFF8B5CF6)),
    _SubjectItem('homeSubjectBiology', Icons.biotech, Color(0xFF16A34A)),
    _SubjectItem('homeSubjectHistory', Icons.history_edu, Color(0xFFF97316)),
    _SubjectItem('homeSubjectPhysics', Icons.rocket_launch, Color(0xFFEF4444)),
    _SubjectItem('homeSubjectKhmer', Icons.menu_book, Color(0xFF0EA5E9)),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 920 ? 4 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _subjects.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AppSizes.spacing16,
        mainAxisSpacing: AppSizes.spacing16,
        childAspectRatio: width >= 620 ? 1.05 : 1.15,
      ),
      itemBuilder: (context, index) => _SubjectTile(subject: _subjects[index]),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({required this.subject});

  final _SubjectItem subject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: subject.color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: subject.color.withValues(alpha: 0.22),
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: subject.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(subject.icon, color: subject.color, size: 30),
              ),
              const SizedBox(height: AppSizes.spacing12),
              Text(
                context.l10n.text(subject.titleKey),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendedLessons extends StatelessWidget {
  const _RecommendedLessons();

  static const _lessons = [
    _LessonItem(
      'homeLessonAlgebra',
      'homeLessonAlgebraSubject',
      'homeDuration18',
      Icons.calculate,
    ),
    _LessonItem(
      'homeLessonChemicalBonds',
      'homeLessonChemistrySubject',
      'homeDuration24',
      Icons.science,
    ),
    _LessonItem(
      'homeLessonCellStructure',
      'homeLessonBiologySubject',
      'homeDuration16',
      Icons.biotech,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _lessons
          .map(
            (lesson) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spacing12),
              child: _LessonListTile(lesson: lesson),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _LessonListTile extends StatelessWidget {
  const _LessonListTile({required this.lesson});

  final _LessonItem lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _DashboardPanel(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              lesson.icon,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: AppSizes.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.text(lesson.titleKey),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  context.l10n.text(lesson.subjectKey),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            context.l10n.text(lesson.durationKey),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressStatsCard extends StatelessWidget {
  const _ProgressStatsCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.text('homeYourProgress'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSizes.spacing24),
          const _StatRow(
            icon: Icons.schedule,
            color: Color(0xFF2563EB),
            labelKey: 'homeTotalStudyTime',
            value: '24h 15m',
          ),
          const SizedBox(height: AppSizes.spacing24),
          const _StatRow(
            icon: Icons.task_alt,
            color: Color(0xFF16A34A),
            labelKey: 'homeLessonsCompleted',
            value: '42',
          ),
        ],
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _DashboardPanel(
      child: Column(
        children: [
          Text(
            context.l10n.text('homeDailyGoal'),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            context.l10n.text('homeDailyGoalMessage'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.spacing24),
          const SizedBox(
            width: 132,
            height: 132,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 0.8,
                  strokeWidth: 12,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Color(0xFFE1E2ED),
                  color: Color(0xFFFBBF24),
                ),
                Center(
                  child: Text(
                    '80%',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel({
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.spacing24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.color,
    required this.labelKey,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String labelKey;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: AppSizes.spacing16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.text(labelKey),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSizes.spacing4),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StudentAvatar extends StatelessWidget {
  const _StudentAvatar({this.imageUrl, this.name});

  final String? imageUrl;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _AvatarInitial(name: name);
                },
              )
            : _AvatarInitial(name: name),
      ),
    );
  }
}

class _AvatarInitial extends StatelessWidget {
  const _AvatarInitial({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final initial = (name == null || name!.trim().isEmpty)
        ? 'S'
        : name!.trim().substring(0, 1).toUpperCase();

    return ColoredBox(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Text(
          initial,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _LessonArtwork extends StatelessWidget {
  const _LessonArtwork();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFFF97316)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -18,
            child: _ArtworkCircle(size: 96, opacity: 0.18),
          ),
          Positioned(
            left: -22,
            bottom: -22,
            child: _ArtworkCircle(size: 118, opacity: 0.16),
          ),
          Center(child: Icon(Icons.functions, color: Colors.white, size: 72)),
          Positioned(
            left: 18,
            bottom: 16,
            child: Text(
              'v = u + at',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtworkCircle extends StatelessWidget {
  const _ArtworkCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SubjectItem {
  const _SubjectItem(this.titleKey, this.icon, this.color);

  final String titleKey;
  final IconData icon;
  final Color color;
}

class _LessonItem {
  const _LessonItem(
    this.titleKey,
    this.subjectKey,
    this.durationKey,
    this.icon,
  );

  final String titleKey;
  final String subjectKey;
  final String durationKey;
  final IconData icon;
}

abstract final class _HomeColors {
  static const purple = Color(0xFF8B5CF6);
}

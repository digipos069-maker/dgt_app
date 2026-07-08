import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
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
    final user = switch (ref.watch(authControllerProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        titleSpacing: AppSizes.spacing16,
        title: Row(
          children: [
            const _StudentAvatar(),
            const SizedBox(width: AppSizes.spacing12),
            Flexible(
              child: Text(
                'EduCambodia',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
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
      body: const SafeArea(child: _HomeDashboard()),
      bottomNavigationBar: const _HomeBottomNavigation(),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 920;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isWide ? 40 : AppSizes.spacing16,
        AppSizes.spacing24,
        isWide ? 40 : AppSizes.spacing16,
        isWide ? AppSizes.spacing32 : 96,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SearchField(),
              const SizedBox(height: AppSizes.spacing24),
              const _WelcomeSummary(),
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
          'Continue Learning',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSizes.spacing16),
        const _ContinueLearningCard(),
        const SizedBox(height: AppSizes.spacing32),
        Text(
          'Popular Subjects',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSizes.spacing16),
        const _SubjectGrid(),
        const SizedBox(height: AppSizes.spacing32),
        Text(
          'Recommended Lessons',
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
            hintText: 'Search lessons, subjects...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
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
  const _WelcomeSummary();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF16A34A)],
        ),
      ),
      padding: const EdgeInsets.all(AppSizes.spacing24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning, Student',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  'You have 3 lessons planned today. Start with Physics to keep your weekly goal on track.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
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
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 38),
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
    final theme = Theme.of(context);
    final isCompact = MediaQuery.sizeOf(context).width < 620;
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: const AspectRatio(aspectRatio: 16 / 10, child: _LessonArtwork()),
    );

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              Container(height: 8, color: _HomeColors.purple),
              Padding(
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
          'Physics - Grade 11',
          style: theme.textTheme.labelMedium?.copyWith(
            color: _HomeColors.purple,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          'Kinematics',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          'Master motion, velocity, and acceleration with interactive simulations.',
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
              'Progress',
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
    _SubjectItem('Math', Icons.calculate, Color(0xFF2563EB)),
    _SubjectItem('Chemistry', Icons.science, Color(0xFF8B5CF6)),
    _SubjectItem('Biology', Icons.biotech, Color(0xFF16A34A)),
    _SubjectItem('History', Icons.history_edu, Color(0xFFF97316)),
    _SubjectItem('Physics', Icons.rocket_launch, Color(0xFFEF4444)),
    _SubjectItem('Khmer', Icons.menu_book, Color(0xFF0EA5E9)),
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
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
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
                subject.title,
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
    _LessonItem('Algebra Basics', 'Math - Grade 10', '18 min', Icons.calculate),
    _LessonItem(
      'Chemical Bonds',
      'Chemistry - Grade 11',
      '24 min',
      Icons.science,
    ),
    _LessonItem('Cell Structure', 'Biology - Grade 9', '16 min', Icons.biotech),
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
              borderRadius: BorderRadius.circular(8),
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
                  lesson.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  lesson.subject,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            lesson.duration,
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
            'Your Progress',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSizes.spacing24),
          const _StatRow(
            icon: Icons.schedule,
            color: Color(0xFF2563EB),
            label: 'Total Study Time',
            value: '24h 15m',
          ),
          const SizedBox(height: AppSizes.spacing24),
          const _StatRow(
            icon: Icons.task_alt,
            color: Color(0xFF16A34A),
            label: 'Lessons Completed',
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
            'Daily Goal',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            'Almost there! Keep going.',
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
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
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
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
                label,
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

class _HomeBottomNavigation extends StatelessWidget {
  const _HomeBottomNavigation();

  static const _items = [
    _BottomNavItem('Home', Icons.home),
    _BottomNavItem('Grades', Icons.grade),
    _BottomNavItem('Subjects', Icons.school),
    _BottomNavItem('My Learning', Icons.menu_book),
    _BottomNavItem('Profile', Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width >= 720) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Material(
      elevation: 12,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              for (final (index, item) in _items.indexed)
                Expanded(
                  child: _BottomNavButton(item: item, isSelected: index == 0),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({required this.item, required this.isSelected});

  final _BottomNavItem item;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.spacing8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: color, size: 24),
            const SizedBox(height: AppSizes.spacing4),
            Flexible(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentAvatar extends StatelessWidget {
  const _StudentAvatar();

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
        child: ColoredBox(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Center(
            child: Text(
              'S',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w900,
              ),
            ),
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
  const _SubjectItem(this.title, this.icon, this.color);

  final String title;
  final IconData icon;
  final Color color;
}

class _BottomNavItem {
  const _BottomNavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _LessonItem {
  const _LessonItem(this.title, this.subject, this.duration, this.icon);

  final String title;
  final String subject;
  final String duration;
  final IconData icon;
}

abstract final class _HomeColors {
  static const purple = Color(0xFF8B5CF6);
}

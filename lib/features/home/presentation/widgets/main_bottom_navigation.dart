import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../../auth/presentation/pages/home_page.dart';
import '../pages/ai_tutor_page.dart';
import '../pages/learning_center_page.dart';
import '../pages/my_learning_page.dart';
import '../pages/resource_page.dart';

class MainBottomNavigation extends StatelessWidget {
  const MainBottomNavigation({required this.selectedIndex, super.key});

  final int selectedIndex;

  static const _items = [
    _BottomNavItem('menuHome', Icons.home, HomePage.routeName),
    _BottomNavItem(
      'menuLearningCenter',
      Icons.school,
      LearningCenterPage.routeName,
    ),
    _BottomNavItem('menuMyLearning', Icons.menu_book, MyLearningPage.routeName),
    _BottomNavItem(
      'menuAiTutor',
      Icons.smart_toy_outlined,
      AiTutorPage.routeName,
    ),
    _BottomNavItem(
      'menuResource',
      Icons.folder_copy_outlined,
      ResourcePage.routeName,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(
                alpha: isDark ? 0.58 : 0.72,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.14 : 0.55),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: SizedBox(
              height: 72,
              child: Row(
                children: [
                  for (final (index, item) in _items.indexed)
                    Expanded(
                      child: _BottomNavButton(
                        item: item,
                        isSelected: index == selectedIndex,
                      ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing4,
        vertical: AppSizes.spacing8,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: isSelected ? null : () => context.goNamed(item.routeName),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.16)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.48)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, color: color, size: 23),
                const SizedBox(height: AppSizes.spacing4),
                Flexible(
                  child: Text(
                    context.l10n.text(item.labelKey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  const _BottomNavItem(this.labelKey, this.icon, this.routeName);

  final String labelKey;
  final IconData icon;
  final String routeName;
}

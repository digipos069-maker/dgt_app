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
                  child: _BottomNavButton(
                    item: item,
                    isSelected: index == selectedIndex,
                  ),
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
      onTap: isSelected ? null : () => context.goNamed(item.routeName),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.spacing8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: color, size: 24),
            const SizedBox(height: AppSizes.spacing4),
            Flexible(
              child: Text(
                context.l10n.text(item.labelKey),
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

class _BottomNavItem {
  const _BottomNavItem(this.labelKey, this.icon, this.routeName);

  final String labelKey;
  final IconData icon;
  final String routeName;
}

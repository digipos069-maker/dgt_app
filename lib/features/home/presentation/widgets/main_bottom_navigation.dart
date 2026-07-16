import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../../auth/presentation/pages/home_page.dart';
import '../pages/ai_tutor_page.dart';
import '../pages/basic_course_page.dart';
import '../pages/grade_list_page.dart';
import '../pages/resource_page.dart';

class MainBottomNavigation extends StatefulWidget {
  const MainBottomNavigation({required this.selectedIndex, super.key});

  final int selectedIndex;

  static const _items = [
    _BottomNavItem('menuHome', Icons.home_outlined, HomePage.routeName),
    _BottomNavItem(
      'menuLearningCenter',
      Icons.school_outlined,
      GradeListPage.routeName,
    ),
    _BottomNavItem(
      'menuBasicCourse',
      Icons.menu_book_outlined,
      BasicCoursePage.routeName,
    ),
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
  State<MainBottomNavigation> createState() => _MainBottomNavigationState();
}

class _MainBottomNavigationState extends State<MainBottomNavigation> {
  static int _lastSelectedIndex = 0;

  late double _fromIndex;
  late double _targetIndex;
  double _itemWidth = 72;
  double _dragOffset = 0;
  bool _isPressing = false;

  @override
  void initState() {
    super.initState();
    _fromIndex = _lastSelectedIndex.toDouble();
    _targetIndex = widget.selectedIndex.toDouble();
    _lastSelectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant MainBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex == widget.selectedIndex) {
      return;
    }
    _fromIndex = oldWidget.selectedIndex.toDouble();
    _targetIndex = widget.selectedIndex.toDouble();
    _lastSelectedIndex = widget.selectedIndex;
  }

  void _updateDrag(double offset) {
    final maxLeftDrag = -widget.selectedIndex * _itemWidth;
    final maxRightDrag =
        (MainBottomNavigation._items.length - 1 - widget.selectedIndex) *
        _itemWidth;
    setState(() => _dragOffset = offset.clamp(maxLeftDrag, maxRightDrag));
  }

  void _navigateToIndex(
    BuildContext context,
    int targetIndex, {
    bool keepDroppedPosition = false,
  }) {
    if (targetIndex == widget.selectedIndex) {
      return;
    }
    _lastSelectedIndex = keepDroppedPosition
        ? targetIndex
        : widget.selectedIndex;
    context.goNamed(MainBottomNavigation._items[targetIndex].routeName);
  }

  void _endDrag(BuildContext context) {
    final threshold = (_itemWidth * 0.34).clamp(34.0, 58.0);
    final targetDelta = _dragOffset.abs() >= threshold
        ? (_dragOffset / _itemWidth).round()
        : 0;
    if (targetDelta == 0) {
      setState(() {
        _dragOffset = 0;
        _isPressing = false;
      });
      return;
    }

    final targetIndex = (widget.selectedIndex + targetDelta).clamp(
      0,
      MainBottomNavigation._items.length - 1,
    );
    if (targetIndex == widget.selectedIndex) {
      setState(() {
        _dragOffset = 0;
        _isPressing = false;
      });
      return;
    }

    _isPressing = false;
    _navigateToIndex(context, targetIndex, keepDroppedPosition: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (_) => setState(() => _isPressing = true),
        onHorizontalDragUpdate: (details) =>
            _updateDrag(_dragOffset + details.delta.dx),
        onHorizontalDragEnd: (_) => _endDrag(context),
        onHorizontalDragCancel: () {
          setState(() {
            _dragOffset = 0;
            _isPressing = false;
          });
        },
        onLongPressStart: (_) => setState(() => _isPressing = true),
        onLongPressMoveUpdate: (details) =>
            _updateDrag(details.offsetFromOrigin.dx),
        onLongPressEnd: (_) => _endDrag(context),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          scale: _isPressing ? 0.985 : 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.surface.withValues(
                        alpha: isDark ? 0.52 : 0.78,
                      ),
                      theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: isDark ? 0.34 : 0.56,
                      ),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.16 : 0.62),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.38 : 0.16,
                      ),
                      blurRadius: 34,
                      offset: const Offset(0, 16),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(
                        alpha: isDark ? 0.04 : 0.38,
                      ),
                      blurRadius: 18,
                      offset: const Offset(-8, -10),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 68,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth =
                          constraints.maxWidth /
                          MainBottomNavigation._items.length;
                      _itemWidth = itemWidth;

                      return Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _LiquidGlassPainter(
                                color: theme.colorScheme.primary,
                                isDark: isDark,
                              ),
                            ),
                          ),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: _fromIndex,
                              end: _targetIndex,
                            ),
                            duration: Duration(
                              milliseconds: _isPressing ? 80 : 520,
                            ),
                            curve: Curves.easeOutCubic,
                            onEnd: () {
                              if (!mounted || _fromIndex == _targetIndex) {
                                return;
                              }
                              setState(() => _fromIndex = _targetIndex);
                            },
                            builder: (context, animatedIndex, child) {
                              final totalTravel = (_targetIndex - _fromIndex)
                                  .abs();
                              final progress = totalTravel == 0
                                  ? 1.0
                                  : 1 -
                                        ((animatedIndex - _targetIndex).abs() /
                                            totalTravel);
                              final wave = math.sin(progress * math.pi);
                              final morphAmount = _isPressing
                                  ? 0.20
                                  : wave * totalTravel.clamp(0.0, 2.0) * 0.28;
                              final stretch = itemWidth * morphAmount;
                              final blobWidth = itemWidth - 4 + stretch;
                              final centerX =
                                  (animatedIndex * itemWidth) +
                                  (itemWidth / 2) +
                                  _dragOffset;
                              final clampedCenter = centerX.clamp(
                                itemWidth / 2,
                                constraints.maxWidth - (itemWidth / 2),
                              );
                              final left = (clampedCenter - (blobWidth / 2))
                                  .clamp(
                                    2.0,
                                    constraints.maxWidth - blobWidth - 2,
                                  );

                              return Positioned(
                                left: left,
                                top: 2,
                                width: blobWidth,
                                height: 64,
                                child: _LiquidSelectionBlob(
                                  isPressing: _isPressing,
                                  morphAmount: morphAmount,
                                ),
                              );
                            },
                          ),
                          Row(
                            children: [
                              for (final (index, item)
                                  in MainBottomNavigation._items.indexed)
                                Expanded(
                                  child: _BottomNavButton(
                                    item: item,
                                    isSelected: index == widget.selectedIndex,
                                    isPressed:
                                        _isPressing &&
                                        index == widget.selectedIndex,
                                    onTap: () =>
                                        _navigateToIndex(context, index),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({
    required this.item,
    required this.isSelected,
    required this.isPressed,
    required this.onTap,
  });

  final _BottomNavItem item;
  final bool isSelected;
  final bool isPressed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing4,
        vertical: AppSizes.spacing4,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: isSelected ? null : onTap,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            scale: isPressed ? 0.92 : 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: isSelected ? 33 : 28,
                  height: isSelected ? 33 : 28,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Icon(item.icon, color: color, size: 22),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    style:
                        theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontSize: isSelected ? 13.5 : 12.5,
                          fontWeight: isSelected
                              ? FontWeight.w900
                              : FontWeight.w600,
                          height: 1.05,
                        ) ??
                        TextStyle(
                          color: color,
                          fontSize: isSelected ? 13.5 : 12.5,
                          fontWeight: isSelected
                              ? FontWeight.w900
                              : FontWeight.w600,
                          height: 1.05,
                        ),
                    child: Text(
                      context.l10n.text(item.labelKey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
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

class _LiquidSelectionBlob extends StatelessWidget {
  const _LiquidSelectionBlob({
    required this.isPressing,
    required this.morphAmount,
  });

  final bool isPressing;
  final double morphAmount;

  @override
  Widget build(BuildContext context) {
    final squeeze = (1 - morphAmount * 0.18).clamp(0.86, 1.0);
    final radius = 28.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      transform: Matrix4.diagonal3Values(
        isPressing ? 1.08 : 1.0,
        isPressing ? 0.94 : squeeze,
        1,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: Colors.white.withValues(alpha: 0.68),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.36),
            blurRadius: 10,
            offset: const Offset(-4, -4),
          ),
        ],
      ),
    );
  }
}

class _LiquidGlassPainter extends CustomPainter {
  const _LiquidGlassPainter({required this.color, required this.isDark});

  final Color color;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.13 : 0.36),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final topPath = Path()
      ..moveTo(18, 13)
      ..cubicTo(size.width * 0.28, 1, size.width * 0.62, 20, size.width - 18, 8)
      ..lineTo(size.width - 18, 24)
      ..cubicTo(size.width * 0.66, 36, size.width * 0.28, 18, 18, 28)
      ..close();
    canvas.drawPath(topPath, highlightPaint);

    final waterPaint = Paint()
      ..color = color.withValues(alpha: isDark ? 0.08 : 0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.76, size.height * 0.74),
        width: size.width * 0.34,
        height: 42,
      ),
      waterPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LiquidGlassPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isDark != isDark;
  }
}

class _BottomNavItem {
  const _BottomNavItem(this.labelKey, this.icon, this.routeName);

  final String labelKey;
  final IconData icon;
  final String routeName;
}

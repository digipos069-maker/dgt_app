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

class MainBottomNavigation extends StatefulWidget {
  const MainBottomNavigation({required this.selectedIndex, super.key});

  final int selectedIndex;

  static const _items = [
    _BottomNavItem('menuHome', Icons.home_outlined, HomePage.routeName),
    _BottomNavItem(
      'menuLearningCenter',
      Icons.school_outlined,
      LearningCenterPage.routeName,
    ),
    _BottomNavItem(
      'menuMyLearning',
      Icons.menu_book_outlined,
      MyLearningPage.routeName,
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
  static const _switchThreshold = 46.0;

  double _dragOffset = 0;
  bool _isPressing = false;

  void _updateDrag(double offset) {
    setState(() => _dragOffset = offset.clamp(-72.0, 72.0));
  }

  void _endDrag(BuildContext context) {
    final direction = _dragOffset.abs() >= _switchThreshold
        ? _dragOffset.sign.toInt()
        : 0;
    setState(() {
      _dragOffset = 0;
      _isPressing = false;
    });

    if (direction == 0) {
      return;
    }

    final targetIndex = (widget.selectedIndex - direction).clamp(
      0,
      MainBottomNavigation._items.length - 1,
    );
    if (targetIndex == widget.selectedIndex) {
      return;
    }

    context.goNamed(MainBottomNavigation._items[targetIndex].routeName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
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
                  height: 76,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth =
                          constraints.maxWidth /
                          MainBottomNavigation._items.length;
                      final selectedLeft =
                          (widget.selectedIndex * itemWidth + _dragOffset)
                              .clamp(0.0, constraints.maxWidth - itemWidth);

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
                          AnimatedPositioned(
                            duration: Duration(
                              milliseconds: _isPressing ? 80 : 360,
                            ),
                            curve: Curves.easeOutBack,
                            left: selectedLeft + 5,
                            top: 7,
                            width: itemWidth - 10,
                            height: 62,
                            child: _LiquidSelectionBlob(
                              isPressing: _isPressing,
                              color: theme.colorScheme.primary,
                            ),
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
  });

  final _BottomNavItem item;
  final bool isSelected;
  final bool isPressed;

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
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: isSelected ? null : () => context.goNamed(item.routeName),
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.46)
                        : Colors.transparent,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.18,
                              ),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(item.icon, color: color, size: 22),
                ),
                const SizedBox(height: AppSizes.spacing4),
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    style:
                        theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontSize: isSelected ? 10.5 : 9.5,
                          fontWeight: isSelected
                              ? FontWeight.w900
                              : FontWeight.w600,
                          height: 1.05,
                        ) ??
                        TextStyle(
                          color: color,
                          fontSize: isSelected ? 10.5 : 9.5,
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
  const _LiquidSelectionBlob({required this.isPressing, required this.color});

  final bool isPressing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      transform: Matrix4.diagonal3Values(isPressing ? 1.08 : 1.0, 0.96, 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: RadialGradient(
          center: const Alignment(-0.55, -0.75),
          radius: 1.45,
          colors: [
            Colors.white.withValues(alpha: 0.70),
            color.withValues(alpha: 0.28),
            color.withValues(alpha: 0.13),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.58)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.24),
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

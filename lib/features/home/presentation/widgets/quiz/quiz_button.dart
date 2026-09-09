import 'package:flutter/material.dart';

import 'package:dgt_app/core/constants/app_sizes.dart';
import 'package:dgt_app/theme/app_colors.dart';

/// Standard button for quiz actions with mandatory background color #032EA1.
class QuizButton extends StatelessWidget {
  const QuizButton({
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isCompleted = false,
    this.backgroundColor,
    super.key,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final bool isLoading;
  final bool isCompleted;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ?? AppColors.brandButton;

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: effectiveBgColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: effectiveBgColor.withValues(alpha: 0.45),
        disabledForegroundColor: Colors.white70,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacing20,
          vertical: AppSizes.spacing12,
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: AppSizes.spacing8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
    );
  }
}

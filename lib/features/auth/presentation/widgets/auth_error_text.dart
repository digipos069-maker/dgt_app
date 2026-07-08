import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';

class AuthErrorText extends StatelessWidget {
  const AuthErrorText({required this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing16),
      child: Text(
        message!,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

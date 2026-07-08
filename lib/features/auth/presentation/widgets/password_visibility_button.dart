import 'package:flutter/material.dart';

class PasswordVisibilityButton extends StatelessWidget {
  const PasswordVisibilityButton({
    required this.isVisible,
    required this.onPressed,
    super.key,
  });

  final bool isVisible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      ),
    );
  }
}

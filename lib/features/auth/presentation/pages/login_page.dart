import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../localization/app_localizations.dart';
import '../../application/auth_controller.dart';
import '../widgets/auth_error_text.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_visibility_button.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  static const routeName = 'login';
  static const routePath = '/login';

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (success && mounted) {
      context.goNamed(HomePage.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return AuthScaffold(
      title: l10n.text('welcomeBack'),
      subtitle: l10n.text('loginSubtitle'),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthErrorText(
              message: authState.hasError ? l10n.text('authFailed') : null,
            ),
            AuthTextField(
              controller: _emailController,
              labelText: l10n.text('email'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) => Validators.email(
                value,
                l10n.text('emailRequired'),
                l10n.text('emailInvalid'),
              ),
            ),
            const SizedBox(height: AppSizes.spacing16),
            AuthTextField(
              controller: _passwordController,
              labelText: l10n.text('password'),
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.done,
              validator: (value) => Validators.password(
                value,
                l10n.text('passwordRequired'),
                l10n.text('passwordShort'),
              ),
              suffixIcon: PasswordVisibilityButton(
                isVisible: _isPasswordVisible,
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),
            ),
            const SizedBox(height: AppSizes.spacing24),
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : Text(l10n.text('login')),
            ),
            const SizedBox(height: AppSizes.spacing12),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => context.goNamed(RegisterPage.routeName),
              child: Text(l10n.text('goToRegister')),
            ),
          ],
        ),
      ),
    );
  }
}

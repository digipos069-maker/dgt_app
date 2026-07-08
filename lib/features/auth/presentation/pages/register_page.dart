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
import 'login_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  static const routeName = 'register';
  static const routePath = '/register';

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _grade;
  bool _isPasswordVisible = false;

  static const _grades = [
    'Grade 7',
    'Grade 8',
    'Grade 9',
    'Grade 10',
    'Grade 11',
    'Grade 12',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .register(
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          grade: _grade!,
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
      title: l10n.text('createAccount'),
      subtitle: l10n.text('registerSubtitle'),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthErrorText(
              message: authState.hasError ? l10n.text('authFailed') : null,
            ),
            AuthTextField(
              controller: _usernameController,
              labelText: l10n.text('username'),
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  Validators.required(value, l10n.text('usernameRequired')),
            ),
            const SizedBox(height: AppSizes.spacing16),
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
              textInputAction: TextInputAction.next,
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
            const SizedBox(height: AppSizes.spacing16),
            DropdownButtonFormField<String>(
              initialValue: _grade,
              decoration: InputDecoration(labelText: l10n.text('grade')),
              items: _grades
                  .map((grade) {
                    return DropdownMenuItem(value: grade, child: Text(grade));
                  })
                  .toList(growable: false),
              onChanged: isLoading
                  ? null
                  : (value) => setState(() => _grade = value),
              validator: (value) =>
                  Validators.required(value, l10n.text('gradeRequired')),
            ),
            const SizedBox(height: AppSizes.spacing24),
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : Text(l10n.text('register')),
            ),
            const SizedBox(height: AppSizes.spacing12),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => context.goNamed(LoginPage.routeName),
              child: Text(l10n.text('goToLogin')),
            ),
          ],
        ),
      ),
    );
  }
}

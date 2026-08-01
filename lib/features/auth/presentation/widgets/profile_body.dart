import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../domain/models/profile_models.dart';
import '../../domain/models/user_model.dart';

class ProfileBody extends StatelessWidget {
  const ProfileBody({
    required this.user,
    required this.isProfileLoading,
    required this.onPaymentHistory,
    required this.onLogout,
    super.key,
  });

  final UserModel? user;
  final bool isProfileLoading;
  final VoidCallback onPaymentHistory;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = GoogleFonts.battambangTextTheme(theme.textTheme);

    return Theme(
      data: theme.copyWith(textTheme: textTheme),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            10,
            24,
            10,
            AppSizes.pageBottomPadding,
          ),
          physics: const ClampingScrollPhysics(),
          child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfileIdentity(user: user),
                const SizedBox(height: AppSizes.spacing32),
                _PersonalInformation(user: user),
                const SizedBox(height: AppSizes.spacing32),
                _SubscriptionInformation(
                  subscriptions: user?.subscriptions ?? const [],
                  isLoading: isProfileLoading,
                ),
                const SizedBox(height: AppSizes.spacing32),
                _AccountInformation(
                  onPaymentHistory: onPaymentHistory,
                  onLogout: onLogout,
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

class _SubscriptionInformation extends StatelessWidget {
  const _SubscriptionInformation({
    required this.subscriptions,
    required this.isLoading,
  });

  final List<SubscriptionModel> subscriptions;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.text('subscriptionInformation'),
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSizes.spacing12),
        if (isLoading && subscriptions.isEmpty)
          const _ProfilePanel(child: Center(child: CircularProgressIndicator()))
        else if (subscriptions.isEmpty)
          _ProfilePanel(
            child: Text(
              context.l10n.text('noActiveSubscription'),
              textAlign: TextAlign.center,
            ),
          )
        else
          for (final subscription in subscriptions) ...[
            _SubscriptionCard(subscription: subscription),
            if (subscription != subscriptions.last)
              const SizedBox(height: AppSizes.spacing12),
          ],
      ],
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.subscription});

  final SubscriptionModel subscription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planName = subscription.plan.name.trim().isEmpty
        ? context.l10n.text('notProvided')
        : subscription.plan.name;

    return _ProfilePanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.workspace_premium_outlined,
              color: theme.colorScheme.onPrimaryContainer,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSizes.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.text('currentPlan'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  planName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subscription.endAt != null) ...[
                  const SizedBox(height: AppSizes.spacing8),
                  Text(
                    '${context.l10n.text('subscriptionEnds')} ${_formatDate(subscription.endAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _StatusBadge(status: subscription.status),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized = status.toLowerCase();
    final isSuccess = normalized == 'active' || normalized == 'success';
    final foreground = isSuccess
        ? const Color(0xFF166534)
        : theme.colorScheme.onPrimaryContainer;
    final background = isSuccess
        ? const Color(0xFFDCFCE7)
        : theme.colorScheme.primaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _localizedStatus(context, normalized),
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({required this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = _displayValue(context, user?.username);
    final role = user?.roles.isNotEmpty == true ? user!.roles.first : null;
    final grade = user?.grade?.trim();
    final subtitle = [
      context.l10n.text('profileLearner'),
      if (role != null && role.trim().isNotEmpty) role,
    ].join(' - ');

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primaryContainer,
                border: Border.all(color: theme.colorScheme.surface, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _ProfileImage(imageUrl: user?.imageUrl, name: name),
            ),
            Positioned(
              right: -2,
              bottom: 2,
              child: Material(
                color: theme.colorScheme.primary,
                shape: const CircleBorder(),
                elevation: 3,
                child: IconButton(
                  tooltip: context.l10n.text('edit'),
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined),
                  color: theme.colorScheme.onPrimary,
                  iconSize: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing16),
        Text(
          name,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSizes.spacing4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (grade != null && grade.isNotEmpty) ...[
          const SizedBox(height: AppSizes.spacing12),
          _GradeBadge(grade: grade),
        ],
      ],
    );
  }
}

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({required this.grade});

  final String grade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefix = context.l10n.text('gradePrefix');
    final label = grade.toLowerCase().startsWith(prefix.toLowerCase())
        ? grade
        : '$prefix $grade';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.72),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.school_outlined,
            size: 18,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: AppSizes.spacing8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalInformation extends StatelessWidget {
  const _PersonalInformation({required this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.text('personalInformation'),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(context.l10n.text('edit')),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing12),
        _ProfilePanel(
          child: Column(
            children: [
              _InformationRow(
                icon: Icons.person_outline,
                label: context.l10n.text('profileName'),
                value: _displayValue(context, user?.username),
                tone: _ProfileTone.primary,
              ),
              const SizedBox(height: AppSizes.spacing20),
              _InformationRow(
                icon: Icons.mail_outline,
                label: context.l10n.text('profileEmail'),
                value: _displayValue(context, user?.email),
                tone: _ProfileTone.secondary,
              ),
              const SizedBox(height: AppSizes.spacing20),
              _InformationRow(
                icon: Icons.call_outlined,
                label: context.l10n.text('profilePhone'),
                value: _displayValue(context, user?.phone),
                tone: _ProfileTone.primary,
              ),
              const SizedBox(height: AppSizes.spacing20),
              _InformationRow(
                icon: Icons.location_on_outlined,
                label: context.l10n.text('profileAddress'),
                value: _displayValue(context, user?.address),
                tone: _ProfileTone.neutral,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountInformation extends StatelessWidget {
  const _AccountInformation({
    required this.onPaymentHistory,
    required this.onLogout,
  });

  final VoidCallback onPaymentHistory;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.text('accountInformation'),
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSizes.spacing12),
        _ProfilePanel(
          padding: const EdgeInsets.all(AppSizes.spacing8),
          child: Column(
            children: [
              _AccountAction(
                icon: Icons.security_outlined,
                label: context.l10n.text('accountSecurity'),
                tone: _ProfileTone.secondary,
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              _AccountAction(
                icon: Icons.payments_outlined,
                label: context.l10n.text('paymentHistory'),
                tone: _ProfileTone.primary,
                onTap: onPaymentHistory,
              ),
              const Divider(height: 1, indent: 56),
              _AccountAction(
                icon: Icons.logout,
                label: context.l10n.text('logout'),
                tone: _ProfileTone.error,
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.spacing24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final String value;
  final _ProfileTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _toneColors(context, tone);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.background,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colors.foreground, size: 22),
        ),
        const SizedBox(width: AppSizes.spacing16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.spacing4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountAction extends StatelessWidget {
  const _AccountAction({
    required this.icon,
    required this.label,
    required this.tone,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final _ProfileTone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _toneColors(context, tone);

    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing8,
        vertical: AppSizes.spacing4,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colors.foreground, size: 22),
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.text,
          fontWeight: FontWeight.w800,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: colors.foreground),
    );
  }
}

class _ProfileImage extends StatelessWidget {
  const _ProfileImage({required this.imageUrl, required this.name});

  final String? imageUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _ProfileInitial(name: name),
      );
    }
    return _ProfileInitial(name: name);
  }
}

class _ProfileInitial extends StatelessWidget {
  const _ProfileInitial({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'S' : name.trim()[0].toUpperCase();

    return ColoredBox(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Text(
          initial,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

enum _ProfileTone { primary, secondary, neutral, error }

({Color background, Color foreground, Color text}) _toneColors(
  BuildContext context,
  _ProfileTone tone,
) {
  final colors = Theme.of(context).colorScheme;

  return switch (tone) {
    _ProfileTone.primary => (
      background: colors.primaryContainer,
      foreground: colors.onPrimaryContainer,
      text: colors.onSurface,
    ),
    _ProfileTone.secondary => (
      background: colors.secondaryContainer,
      foreground: colors.onSecondaryContainer,
      text: colors.onSurface,
    ),
    _ProfileTone.neutral => (
      background: colors.surfaceContainerHighest,
      foreground: colors.onSurfaceVariant,
      text: colors.onSurface,
    ),
    _ProfileTone.error => (
      background: colors.errorContainer,
      foreground: colors.error,
      text: colors.error,
    ),
  };
}

String _displayValue(BuildContext context, String? value) {
  if (value == null || value.trim().isEmpty) {
    return context.l10n.text('notProvided');
  }
  return value.trim();
}

String _localizedStatus(BuildContext context, String status) {
  return switch (status) {
    'active' => context.l10n.text('statusActive'),
    'success' => context.l10n.text('statusSuccess'),
    'pending' => context.l10n.text('statusPending'),
    'failed' => context.l10n.text('statusFailed'),
    _ => status,
  };
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

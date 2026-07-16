import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../domain/models/profile_models.dart';

class PaymentHistoryBody extends StatelessWidget {
  const PaymentHistoryBody({
    required this.payments,
    required this.onRefresh,
    super.key,
  });

  final List<PaymentHistoryModel> payments;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = GoogleFonts.battambangTextTheme(theme.textTheme);

    return Theme(
      data: theme.copyWith(textTheme: textTheme),
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: payments.isEmpty
            ? const _EmptyPaymentHistory()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(10, 24, 10, 112),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: payments.length + 1,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSizes.spacing12),
                itemBuilder: (context, index) {
                  final Widget item = index == 0
                      ? _PaymentHistorySummary(count: payments.length)
                      : _PaymentHistoryCard(payment: payments[index - 1]);
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: item,
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _PaymentHistorySummary extends StatelessWidget {
  const _PaymentHistorySummary({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.text('paymentHistoryDescription'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacing12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              count.toString(),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentHistoryCard extends StatelessWidget {
  const _PaymentHistoryCard({required this.payment});

  final PaymentHistoryModel payment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
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
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.account_balance_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatPaymentType(payment.paymentType),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing4),
                    Text(
                      _formatDate(payment.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _PaymentStatusBadge(status: payment.status),
            ],
          ),
          const SizedBox(height: AppSizes.spacing16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _PaymentMetadata(
                  label: context.l10n.text('transactionId'),
                  value: payment.transactionId.isEmpty
                      ? context.l10n.text('notProvided')
                      : payment.transactionId,
                ),
              ),
              const SizedBox(width: AppSizes.spacing16),
              Text(
                _formatAmount(payment),
                textAlign: TextAlign.end,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentMetadata extends StatelessWidget {
  const _PaymentMetadata({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  const _PaymentStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized = status.toLowerCase();
    final (background, foreground) = switch (normalized) {
      'success' ||
      'active' => (const Color(0xFFDCFCE7), const Color(0xFF166534)),
      'failed' => (theme.colorScheme.errorContainer, theme.colorScheme.error),
      _ => (
        theme.colorScheme.primaryContainer,
        theme.colorScheme.onPrimaryContainer,
      ),
    };

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

class _EmptyPaymentHistory extends StatelessWidget {
  const _EmptyPaymentHistory();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.spacing24),
      children: [
        const SizedBox(height: 120),
        Icon(
          Icons.receipt_long_outlined,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: AppSizes.spacing16),
        Text(
          context.l10n.text('paymentHistoryEmpty'),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}

String _formatAmount(PaymentHistoryModel payment) {
  final amount = payment.amount % 1 == 0
      ? payment.amount.toInt().toString()
      : payment.amount.toStringAsFixed(2);
  return payment.currency.isEmpty ? amount : '$amount ${payment.currency}';
}

String _formatPaymentType(String value) {
  if (value.isEmpty) return '-';
  final words = value.split('_');
  return words
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}

String _formatDate(DateTime? date) {
  if (date == null) return '-';
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
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

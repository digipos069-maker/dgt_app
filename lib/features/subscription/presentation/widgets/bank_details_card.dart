import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../domain/models/bank_transfer_info.dart';

class BankDetailsCard extends StatelessWidget {
  const BankDetailsCard({
    required this.bankInfo,
    required this.amountText,
    required this.referenceCode,
    super.key,
  });

  final BankTransferInfo bankInfo;
  final String amountText;
  final String referenceCode;

  void _copy(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label ${context.l10n.text('copiedToClipboard')}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bankInfo.bankName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    Text(
                      bankInfo.accountName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _DetailRow(
            label: context.l10n.text('accountNumber'),
            value: bankInfo.accountNumber,
            onCopy: () => _copy(
              context,
              bankInfo.accountNumber,
              context.l10n.text('accountNumber'),
            ),
          ),
          const SizedBox(height: 10),
          _DetailRow(
            label: context.l10n.text('amountToPay'),
            value: amountText,
            isHighlighted: true,
            onCopy: () => _copy(
              context,
              amountText,
              context.l10n.text('amountToPay'),
            ),
          ),
          const SizedBox(height: 10),
          _DetailRow(
            label: context.l10n.text('transferReference'),
            value: referenceCode,
            onCopy: () => _copy(
              context,
              referenceCode,
              context.l10n.text('transferReference'),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bankInfo.instructions,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.onCopy,
    this.isHighlighted = false,
  });

  final String label;
  final String value;
  final VoidCallback onCopy;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
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
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isHighlighted
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: isHighlighted ? FontWeight.w900 : FontWeight.w700,
                  fontSize: isHighlighted ? 16 : 14,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: context.l10n.text('copy'),
          onPressed: onCopy,
          icon: const Icon(Icons.copy_rounded, size: 18),
          color: theme.colorScheme.primary,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

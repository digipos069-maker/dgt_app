import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../theme/app_colors.dart';

class PayslipUploadWidget extends StatelessWidget {
  const PayslipUploadWidget({
    required this.selectedFileName,
    required this.onFileChanged,
    this.errorMessage,
    super.key,
  });

  final String? selectedFileName;
  final ValueChanged<String?> onFileChanged;
  final String? errorMessage;

  void _showFileSelectionDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.text('uploadPayslip'),
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Theme.of(ctx).colorScheme.secondary,
                      ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  'Select payment receipt to attach:',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppSizes.spacing16),
                _OptionTile(
                  icon: Icons.receipt_long_rounded,
                  title: 'aba_payment_slip_2026.png',
                  subtitle: '1.4 MB • PNG Image',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onFileChanged('aba_payment_slip_2026.png');
                  },
                ),
                const SizedBox(height: 8),
                _OptionTile(
                  icon: Icons.image_outlined,
                  title: 'khqr_transfer_receipt.jpg',
                  subtitle: '2.1 MB • JPG Photo',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onFileChanged('khqr_transfer_receipt.jpg');
                  },
                ),
                const SizedBox(height: 8),
                _OptionTile(
                  icon: Icons.camera_alt_outlined,
                  title: 'camera_capture_receipt.jpg',
                  subtitle: '980 KB • Mobile Scan',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onFileChanged('camera_capture_receipt.jpg');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAttached = selectedFileName != null && selectedFileName!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isAttached)
          InkWell(
            key: const Key('upload_payslip_zone'),
            onTap: () => _showFileSelectionDialog(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: errorMessage != null
                      ? AppColors.error
                      : theme.colorScheme.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.brandButton.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      color: AppColors.brandButton,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing12),
                  Text(
                    context.l10n.text('uploadPayslip'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.text('uploadPayslipDesc'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF16A34A).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
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
                        selectedFileName!,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: Color(0xFF16A34A),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.l10n.text('payslipAttached'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF166534),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.text('changeFile'),
                  onPressed: () => _showFileSelectionDialog(context),
                  icon: const Icon(Icons.sync_rounded, size: 20),
                  color: theme.colorScheme.secondary,
                ),
                IconButton(
                  tooltip: context.l10n.text('removeFile'),
                  onPressed: () => onFileChanged(null),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: AppColors.error,
                ),
              ],
            ),
          ),
        if (errorMessage != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.brandButton.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.brandButton, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: const Icon(Icons.chevron_right_rounded),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../domain/models/bank_transfer_info.dart';
import '../../domain/models/subscription_plan.dart';
import 'bank_details_card.dart';
import 'billing_cycle_toggle.dart';
import 'payment_method_selector.dart';
import 'payslip_upload_widget.dart';
import 'plan_card.dart';
import 'subscription_success_dialog.dart';

Future<void> showUpgradeSubscriptionModal({
  required BuildContext context,
  required VoidCallback onNavigateToPaymentHistory,
  PlanTier? initialPlan,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (ctx) => UpgradeSubscriptionModal(
      initialPlan: initialPlan,
      onNavigateToPaymentHistory: onNavigateToPaymentHistory,
    ),
  );
}

class UpgradeSubscriptionModal extends StatefulWidget {
  const UpgradeSubscriptionModal({
    required this.onNavigateToPaymentHistory,
    this.initialPlan,
    super.key,
  });

  final VoidCallback onNavigateToPaymentHistory;
  final PlanTier? initialPlan;

  @override
  State<UpgradeSubscriptionModal> createState() =>
      _UpgradeSubscriptionModalState();
}

class _UpgradeSubscriptionModalState extends State<UpgradeSubscriptionModal> {
  int _currentStep = 0; // 0: Select Plan, 1: Select Payment, 2: Bank Details & Payslip
  BillingCycle _cycle = BillingCycle.yearly;
  late PlanTier _selectedPlan;
  PaymentMethodType _paymentMethod = PaymentMethodType.bankTransfer;
  String? _attachedPayslip;
  String? _uploadError;
  bool _isSubmitting = false;
  late final String _referenceCode;

  @override
  void initState() {
    super.initState();
    _selectedPlan = widget.initialPlan ??
        PlanTier.defaultPlans.firstWhere(
          (p) => p.isPopular,
          orElse: () => PlanTier.defaultPlans.first,
        );
    final randomDigits = 100000 + Random().nextInt(900000);
    _referenceCode = 'DGT-$randomDigits';
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
      _uploadError = null;
    });
  }

  Future<void> _submitPayment() async {
    if (_attachedPayslip == null || _attachedPayslip!.isEmpty) {
      setState(() {
        _uploadError = context.l10n.text('pleaseUploadPayslip');
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _uploadError = null;
    });

    // Simulate network submission
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    final transactionId = 'TRX-${DateTime.now().millisecondsSinceEpoch % 10000000}';
    final planName = '${_selectedPlan.name} (${_cycle.isMonthly ? context.l10n.text('monthly') : context.l10n.text('yearly')})';
    final amountText = _selectedPlan.formattedPrice(_cycle);

    Navigator.of(context).pop();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SubscriptionSuccessDialog(
        transactionId: transactionId,
        planName: planName,
        amountText: amountText,
        onViewHistory: widget.onNavigateToPaymentHistory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    IconButton(
                      tooltip: context.l10n.text('back'),
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => _goToStep(_currentStep - 1),
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Text(
                      _stepTitle(context),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.text('close'),
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Body
            Flexible(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  overscroll: false,
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 540),
                      child: _buildCurrentStep(context),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stepTitle(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return context.l10n.text('choosePlan');
      case 1:
        return context.l10n.text('paymentMethod');
      case 2:
        return context.l10n.text('bankDetails');
      default:
        return context.l10n.text('upgradePlan');
    }
  }

  Widget _buildCurrentStep(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildPlanSelectionStep(context);
      case 1:
        return _buildPaymentMethodStep(context);
      case 2:
        return _buildBankTransferStep(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPlanSelectionStep(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          context.l10n.text('choosePlanSubtitle'),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSizes.spacing16),
        BillingCycleToggle(
          selectedCycle: _cycle,
          onCycleChanged: (newCycle) {
            setState(() => _cycle = newCycle);
          },
        ),
        const SizedBox(height: AppSizes.spacing20),
        for (final plan in PlanTier.defaultPlans) ...[
          PlanCard(
            plan: plan,
            cycle: _cycle,
            isSelected: _selectedPlan.id == plan.id,
            onSelect: () {
              setState(() => _selectedPlan = plan);
              _goToStep(1);
            },
          ),
          const SizedBox(height: AppSizes.spacing16),
        ],
      ],
    );
  }

  Widget _buildPaymentMethodStep(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Selected Plan Pill
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(
                _selectedPlan.icon,
                color: theme.colorScheme.secondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selectedPlan.name} Plan',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${_selectedPlan.formattedPrice(_cycle)} ${_cycle.isMonthly ? context.l10n.text('perMonth') : context.l10n.text('perYear')}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _goToStep(0),
                child: Text(
                  context.l10n.text('edit'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spacing20),
        Text(
          context.l10n.text('paymentMethodSubtitle'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSizes.spacing12),
        PaymentMethodSelector(
          selectedMethod: _paymentMethod,
          onMethodSelected: (method) {
            setState(() => _paymentMethod = method);
            _goToStep(2);
          },
        ),
        const SizedBox(height: AppSizes.spacing24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => _goToStep(2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Continue with ${context.l10n.text('bankTransfer')}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBankTransferStep(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BankDetailsCard(
          bankInfo: BankTransferInfo.defaultAba,
          amountText: _selectedPlan.formattedPrice(_cycle),
          referenceCode: _referenceCode,
        ),
        const SizedBox(height: AppSizes.spacing20),
        Text(
          context.l10n.text('uploadPayslip'),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        PayslipUploadWidget(
          selectedFileName: _attachedPayslip,
          onFileChanged: (file) {
            setState(() {
              _attachedPayslip = file;
              _uploadError = null;
            });
          },
          errorMessage: _uploadError,
        ),
        const SizedBox(height: AppSizes.spacing24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _isSubmitting ? null : _submitPayment,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.text('submitPayment'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

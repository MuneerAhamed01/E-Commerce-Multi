import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/pricing_breakdown.dart';

/// Subtotal / discount / tax / total panel with promo field and checkout CTA.
class CartSummaryPanel extends StatelessWidget {
  const CartSummaryPanel({
    required this.pricing,
    required this.onApplyPromo,
    required this.onCheckout,
    this.appliedPromoCode,
    this.promoError,
    this.isApplyingPromo = false,
    this.onRemovePromo,
    this.checkoutEnabled = true,
    super.key,
  });

  final PricingBreakdown pricing;
  final ValueChanged<String> onApplyPromo;
  final VoidCallback onCheckout;
  final String? appliedPromoCode;
  final String? promoError;
  final bool isApplyingPromo;
  final VoidCallback? onRemovePromo;
  final bool checkoutEnabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 2,
      color: colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPromoCodeField(
                appliedCode: appliedPromoCode,
                errorText: promoError,
                isApplying: isApplyingPromo,
                onApply: onApplyPromo,
                onRemove: onRemovePromo,
              ),
              const SizedBox(height: AppSpacing.md),
              _Row(
                label: 'Subtotal',
                value: Formatters.currency(pricing.subtotal),
              ),
              if (!pricing.discount.isZero) ...[
                const SizedBox(height: AppSpacing.xs),
                _Row(
                  label: 'Discount',
                  value: '-${Formatters.currency(pricing.discount)}',
                  valueColor: colorScheme.tertiary,
                ),
              ],
              const SizedBox(height: AppSpacing.xs),
              _Row(
                label: 'Tax',
                value: Formatters.currency(pricing.taxPlaceholder),
                labelStyle: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Divider(height: AppSpacing.lg),
              _Row(
                label: 'Total',
                value: Formatters.currency(pricing.total),
                labelStyle: textTheme.titleMedium,
                valueStyle: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Checkout',
                isFullWidth: true,
                onPressed: checkoutEnabled ? onCheckout : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    this.valueColor,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(child: Text(label, style: labelStyle ?? textTheme.bodyMedium)),
        Text(
          value,
          style:
              valueStyle ?? textTheme.bodyMedium?.copyWith(color: valueColor),
        ),
      ],
    );
  }
}

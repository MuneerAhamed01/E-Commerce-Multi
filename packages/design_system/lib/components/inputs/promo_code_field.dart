import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/app_spacing.dart';
import '../../tokens/app_typography.dart';
import '../buttons/app_button.dart';
import 'app_text_field.dart';

/// A promo/coupon code entry field with an inline apply action and result,
/// per docs/08_COMPONENT_LIBRARY.md §5 (`PromoCodeField`). Used in Cart.
///
/// Pass [appliedCode] once the Bloc confirms a code was accepted (renders
/// the success state with a clear/remove affordance via [onRemove]), or
/// [errorText] when the Bloc reports the code was rejected. The field
/// itself holds no business logic - it only reports the raw string the
/// user typed via [onApply].
///
/// ```dart
/// AppPromoCodeField(
///   appliedCode: state.appliedPromoCode,
///   errorText: state.promoError,
///   onApply: (code) => bloc.add(PromoCodeApplied(code)),
///   onRemove: () => bloc.add(const PromoCodeRemoved()),
/// );
/// ```
class AppPromoCodeField extends StatefulWidget {
  const AppPromoCodeField({
    required this.onApply,
    this.appliedCode,
    this.errorText,
    this.onRemove,
    this.isApplying = false,
    super.key,
  });

  final ValueChanged<String> onApply;
  final String? appliedCode;
  final String? errorText;
  final VoidCallback? onRemove;
  final bool isApplying;

  @override
  State<AppPromoCodeField> createState() => _AppPromoCodeFieldState();
}

class _AppPromoCodeFieldState extends State<AppPromoCodeField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.appliedCode != null) {
      final semantic = context.semanticColors;
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: semantic.successContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: semantic.onSuccessContainer,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '"${widget.appliedCode}" applied',
                style: AppTypography.bodyMedium.copyWith(
                  color: semantic.onSuccessContainer,
                ),
              ),
            ),
            if (widget.onRemove != null)
              IconButton(
                icon: Icon(Icons.close, color: semantic.onSuccessContainer),
                tooltip: 'Remove promo code',
                onPressed: widget.onRemove,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppTextField(
            controller: _controller,
            hint: 'Promo code',
            errorText: widget.errorText,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        AppButton(
          label: 'Apply',
          variant: AppButtonVariant.outline,
          isLoading: widget.isApplying,
          onPressed: () {
            final code = _controller.text.trim();
            if (code.isNotEmpty) {
              widget.onApply(code);
            }
          },
        ),
      ],
    );
  }
}

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/app_spacing.dart';
import '../buttons/app_icon_button.dart';
import 'app_card.dart';

/// Interaction mode of an [AppAddressCard]. See
/// docs/08_COMPONENT_LIBRARY.md §2.
enum AppAddressCardVariant {
  /// Tappable for selection (e.g. Checkout's address step) - highlights
  /// when [AppAddressCard.isSelected] is `true`.
  selectable,

  /// Display-only, no selection affordance (e.g. a receipt/order-review
  /// summary).
  readonly,
}

/// An address summary card with select/edit/delete actions, per
/// docs/08_COMPONENT_LIBRARY.md §2 (`AddressCard`). Built on `core`'s
/// [Address] - a legitimate exception to "design_system has zero feature
/// knowledge" because `Address` is itself a cross-feature shared entity
/// with no single owner (docs/05_ARCHITECTURE_GUIDELINES.md §3), unlike
/// `Product`/`Order`/`PaymentMethod`, which stay feature-owned.
///
/// ```dart
/// AppAddressCard(
///   address: address,
///   isDefault: address == defaultAddress,
///   variant: AppAddressCardVariant.selectable,
///   isSelected: address == selectedAddress,
///   onSelect: () => cubit.select(address),
///   onEdit: () => router.go('/addresses/${address.label}/edit'),
///   onDelete: () => cubit.remove(address),
/// );
/// ```
class AppAddressCard extends StatelessWidget {
  const AppAddressCard({
    required this.address,
    this.variant = AppAddressCardVariant.readonly,
    this.isDefault = false,
    this.isSelected = false,
    this.onSelect,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final Address address;
  final AppAddressCardVariant variant;
  final bool isDefault;
  final bool isSelected;
  final VoidCallback? onSelect;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  bool get _isSelectable => variant == AppAddressCardVariant.selectable;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      variant: isSelected ? AppCardVariant.outlined : AppCardVariant.elevated,
      onTap: _isSelectable ? onSelect : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (_isSelectable)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? colorScheme.primary
                        : semantic.disabledForeground,
                  ),
                ),
              Expanded(
                child: Text(
                  address.label ?? 'Address',
                  style: textTheme.titleSmall,
                ),
              ),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Default',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: EdgeInsets.only(left: _isSelectable ? 40 : 0),
            child: Text(
              address.singleLine,
              style: textTheme.bodyMedium?.copyWith(
                color: semantic.disabledForeground,
              ),
            ),
          ),
          if (onEdit != null || onDelete != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  AppIconButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit address',
                    onPressed: onEdit,
                  ),
                if (onDelete != null)
                  AppIconButton(
                    icon: Icons.delete_outline,
                    tooltip: 'Delete address',
                    onPressed: onDelete,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

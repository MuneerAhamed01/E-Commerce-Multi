import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/cart_item.dart';

/// One cart line with quantity stepper and remove action.
class CartLineItem extends StatelessWidget {
  const CartLineItem({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    this.onTap,
    super.key,
  });

  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumb(url: item.imageUrl),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName, style: textTheme.titleSmall),
                    if (item.variantLabel.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        item.variantLabel,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      Formatters.currency(item.unitPrice),
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        AppQuantityStepper(
                          value: item.quantity,
                          min: 1,
                          max: item.maxStock.clamp(1, 99),
                          onChanged: onQuantityChanged,
                        ),
                        const Spacer(),
                        AppIconButton(
                          icon: Icons.delete_outline,
                          tooltip: 'Remove from cart',
                          onPressed: onRemove,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: AppRadii.borderRadiusSm,
      child: ColoredBox(
        color: colorScheme.surfaceContainerHighest,
        child: SizedBox(
          width: 72,
          height: 72,
          child: url.isEmpty
              ? Icon(Icons.image_outlined, color: colorScheme.onSurfaceVariant)
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.broken_image_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
      ),
    );
  }
}

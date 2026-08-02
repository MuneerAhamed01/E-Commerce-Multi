import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';

/// Compact catalog card used in grids and related rows.
class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, required this.onTap, super.key});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final price = product.cheapestVariant.price;
    final inStock = product.variants.any((v) => v.isInStock);

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadii.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: colorScheme.onSurfaceVariant,
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                Formatters.currency(price),
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              if (!inStock) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Out of stock',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';

/// Compact catalog card used in grids and related rows.
///
/// Optional [wishlistAction] is composed by the app shell (e.g. storefront
/// supplies a wishlist heart toggle) so `products` stays free of a
/// `wishlist` package dependency.
class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.onTap,
    this.wishlistAction,
    super.key,
  });

  final Product product;
  final VoidCallback onTap;

  /// Optional heart / remove control overlaid on the media area.
  final Widget? wishlistAction;

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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
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
                    if (wishlistAction != null)
                      Positioned(top: 0, right: 0, child: wishlistAction!),
                  ],
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

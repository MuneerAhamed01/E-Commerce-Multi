import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/featured_product.dart';

/// Horizontal row of featured product cards.
class FeaturedProductRow extends StatelessWidget {
  const FeaturedProductRow({
    required this.products,
    required this.onProductTap,
    this.onViewAllTap,
    super.key,
  });

  final List<FeaturedProduct> products;
  final ValueChanged<FeaturedProduct> onProductTap;
  final VoidCallback? onViewAllTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Featured products', style: textTheme.titleMedium),
            ),
            if (onViewAllTap != null)
              TextButton(
                onPressed: onViewAllTap,
                child: const Text('View all'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 148,
                child: Material(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onProductTap(product),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(
                                  AppRadii.sm,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  color: colorScheme.onSurfaceVariant,
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
                            Formatters.currency(product.price),
                            style: textTheme.titleSmall?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

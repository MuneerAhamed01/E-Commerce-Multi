import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';
import 'product_card.dart';

/// Responsive product grid for listing screens.
class ProductGrid extends StatelessWidget {
  const ProductGrid({
    required this.products,
    required this.onProductTap,
    this.padding,
    super.key,
  });

  final List<Product> products;
  final ValueChanged<Product> onProductTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 900
            ? 4
            : width >= 600
            ? 3
            : 2;
        return GridView.builder(
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 0.68,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onTap: () => onProductTap(product),
            );
          },
        );
      },
    );
  }
}

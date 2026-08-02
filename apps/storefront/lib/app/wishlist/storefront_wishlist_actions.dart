import 'package:flutter/material.dart';
import 'package:products/products.dart';
import 'package:wishlist/wishlist.dart';

/// Shared builders that compose [WishlistToggleButton] into product surfaces
/// without creating a `products` → `wishlist` package dependency.
abstract final class StorefrontWishlistActions {
  static Widget cardToggle(BuildContext context, Product product) {
    return WishlistToggleButton(productId: product.id);
  }

  static Widget detailToggle(
    BuildContext context,
    Product product,
    String? selectedVariantId,
  ) {
    return WishlistToggleButton(
      productId: product.id,
      variantId: selectedVariantId,
    );
  }
}

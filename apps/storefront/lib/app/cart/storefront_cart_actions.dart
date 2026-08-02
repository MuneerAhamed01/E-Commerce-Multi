import 'package:cart/cart.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:products/products.dart';

/// Storefront composition for add-to-cart (avoids products → cart cycle).
abstract final class StorefrontCartActions {
  static Future<void> addFromDetail(
    BuildContext context,
    Product product,
    ProductVariant variant,
  ) async {
    final bloc = context.read<CartBloc>();
    bloc.add(CartItemAdded(productId: product.id, variantId: variant.id));
    AppSnackbar.show(
      context,
      message: 'Added to cart',
      variant: AppSnackbarVariant.success,
      actionLabel: 'View cart',
      onAction: () => context.push(CartRoutes.path),
    );
  }
}

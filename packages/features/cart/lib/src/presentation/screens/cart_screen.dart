import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:products/products.dart';

import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../widgets/cart_line_item.dart';
import '../widgets/cart_summary_panel.dart';

/// Cart management screen (`/cart`).
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is! CartLoaded || state.cart.isEmpty) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () =>
                    context.read<CartBloc>().add(const CartCleared()),
                child: const Text('Clear'),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listenWhen: (prev, next) {
          if (next is! CartLoaded) {
            return false;
          }
          if (prev is! CartLoaded) {
            return next.statusMessage != null || next.checkoutMessage != null;
          }
          return (next.statusMessage != null &&
                  next.statusMessage != prev.statusMessage) ||
              (next.checkoutMessage != null &&
                  next.checkoutMessage != prev.checkoutMessage);
        },
        listener: (context, state) {
          if (state is! CartLoaded) {
            return;
          }
          final message = state.checkoutMessage ?? state.statusMessage;
          if (message == null) {
            return;
          }
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
        builder: (context, state) {
          return switch (state) {
            CartInitial() ||
            CartLoading() => const Center(child: CircularProgressIndicator()),
            CartError(:final message) => AppErrorState(
              title: 'Could not load cart',
              message: message,
              onRetry: () => context.read<CartBloc>().add(const CartRetried()),
            ),
            CartLoaded(:final cart, :final pricing) =>
              cart.isEmpty
                  ? AppEmptyState(
                      title: 'Your cart is empty',
                      message:
                          'Browse the catalog and add items to get started.',
                      ctaLabel: 'Start Shopping',
                      onCtaPressed: () => context.go(ProductRoutes.listPath),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            itemCount: cart.items.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = cart.items[index];
                              return CartLineItem(
                                item: item,
                                onQuantityChanged: (qty) =>
                                    context.read<CartBloc>().add(
                                      CartQuantityChanged(
                                        productId: item.productId,
                                        variantId: item.variantId,
                                        quantity: qty,
                                      ),
                                    ),
                                onRemove: () => context.read<CartBloc>().add(
                                  CartItemRemoved(
                                    productId: item.productId,
                                    variantId: item.variantId,
                                  ),
                                ),
                                onTap: () => context.push(
                                  ProductRoutes.detailPath(item.productId),
                                ),
                              );
                            },
                          ),
                        ),
                        CartSummaryPanel(
                          pricing: pricing,
                          appliedPromoCode: cart.appliedPromoCode,
                          promoError: state.promoError,
                          isApplyingPromo: state.isApplyingPromo,
                          onApplyPromo: (code) => context.read<CartBloc>().add(
                            CartPromoApplied(code),
                          ),
                          onRemovePromo: () => context.read<CartBloc>().add(
                            const CartPromoRemoved(),
                          ),
                          onCheckout: () => context.read<CartBloc>().add(
                            const CartCheckoutPressed(),
                          ),
                        ),
                      ],
                    ),
          };
        },
      ),
    );
  }
}

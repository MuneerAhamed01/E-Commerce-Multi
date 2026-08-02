import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:products/products.dart';

import '../cubit/wishlist_cubit.dart';
import '../cubit/wishlist_state.dart';
import '../widgets/wishlist_grid.dart';

/// Authenticated wishlist management screen (shell `/wishlist`).
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: BlocBuilder<WishlistCubit, WishlistState>(
        builder: (context, state) {
          return switch (state) {
            WishlistInitial() || WishlistLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            WishlistGuest() => AppEmptyState(
              title: 'Sign in to view your wishlist',
              message: 'Save items you love and find them here later.',
              ctaLabel: 'Browse Products',
              onCtaPressed: () => context.go(ProductRoutes.listPath),
            ),
            WishlistError(:final message) => AppErrorState(
              title: 'Could not load wishlist',
              message: message,
              onRetry: () => context.read<WishlistCubit>().retry(),
            ),
            WishlistLoaded(:final orderedProducts) =>
              orderedProducts.isEmpty
                  ? AppEmptyState(
                      title: 'Your wishlist is empty',
                      message: 'Save items you love for later.',
                      ctaLabel: 'Browse Products',
                      onCtaPressed: () => context.go(ProductRoutes.listPath),
                    )
                  : WishlistGrid(
                      products: orderedProducts,
                      onProductTap: (product) =>
                          context.push(ProductRoutes.detailPath(product.id)),
                      onRemove: (product) =>
                          context.read<WishlistCubit>().remove(product.id),
                    ),
          };
        },
      ),
    );
  }
}

import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../bloc/product_detail_bloc.dart';
import '../cubit/reviews_cubit.dart';
import '../routing/product_routes.dart';
import '../widgets/product_card.dart';
import '../widgets/product_gallery.dart';
import '../widgets/rating_summary.dart';
import '../widgets/review_list.dart';
import '../widgets/review_submission_form.dart';
import '../widgets/variant_selector.dart';

/// Full product detail with variants, related items, and reviews.
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({
    required this.productId,
    this.detailBloc,
    this.reviewsCubit,
    this.wishlistActionBuilder,
    this.relatedWishlistActionBuilder,
    this.onAddToCart,
    super.key,
  });

  final String productId;
  final ProductDetailBloc? detailBloc;
  final ReviewsCubit? reviewsCubit;

  /// Optional wishlist control for the primary product (app shell composes).
  final Widget Function(
    BuildContext context,
    Product product,
    String? selectedVariantId,
  )?
  wishlistActionBuilder;

  /// Optional wishlist control for related product cards.
  final Widget Function(BuildContext context, Product product)?
  relatedWishlistActionBuilder;

  /// Optional add-to-cart handler composed by the app shell (avoids a
  /// `products` → `cart` package dependency).
  final Future<void> Function(
    BuildContext context,
    Product product,
    ProductVariant variant,
  )?
  onAddToCart;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              (detailBloc ?? getIt<ProductDetailBloc>())
                ..add(ProductDetailStarted(productId)),
        ),
        BlocProvider(
          create: (_) =>
              (reviewsCubit ?? getIt<ReviewsCubit>())..load(productId),
        ),
      ],
      child: _ProductDetailView(
        wishlistActionBuilder: wishlistActionBuilder,
        relatedWishlistActionBuilder: relatedWishlistActionBuilder,
        onAddToCart: onAddToCart,
      ),
    );
  }
}

class _ProductDetailView extends StatelessWidget {
  const _ProductDetailView({
    this.wishlistActionBuilder,
    this.relatedWishlistActionBuilder,
    this.onAddToCart,
  });

  final Widget Function(
    BuildContext context,
    Product product,
    String? selectedVariantId,
  )?
  wishlistActionBuilder;
  final Widget Function(BuildContext context, Product product)?
  relatedWishlistActionBuilder;
  final Future<void> Function(
    BuildContext context,
    Product product,
    ProductVariant variant,
  )?
  onAddToCart;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductDetailBloc, ProductDetailState>(
      listenWhen: (prev, next) {
        if (next is! ProductDetailLoaded) {
          return false;
        }
        if (prev is! ProductDetailLoaded) {
          return next.statusMessage != null;
        }
        return next.statusMessage != null &&
            next.statusMessage != prev.statusMessage;
      },
      listener: (context, state) {
        if (state is ProductDetailLoaded && state.statusMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.statusMessage!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(switch (state) {
              ProductDetailLoaded(:final product) => product.name,
              _ => 'Product',
            }),
          ),
          body: switch (state) {
            ProductDetailInitial() ||
            ProductDetailLoading() => const _DetailSkeleton(),
            ProductDetailError(:final message) => AppErrorState(
              title: 'Could not load product',
              message: message,
              onRetry: () => context.read<ProductDetailBloc>().add(
                const ProductDetailRetried(),
              ),
            ),
            ProductDetailLoaded(
              :final product,
              :final selectedVariantId,
              :final relatedProducts,
            ) =>
              _LoadedBody(
                product: product,
                selectedVariantId: selectedVariantId,
                relatedProducts: relatedProducts,
                wishlistActionBuilder: wishlistActionBuilder,
                relatedWishlistActionBuilder: relatedWishlistActionBuilder,
              ),
          },
          bottomNavigationBar: state is ProductDetailLoaded
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: AppButton(
                      label: state.canAddToCart
                          ? 'Add to cart'
                          : 'Out of stock',
                      isFullWidth: true,
                      onPressed: () {
                        final loaded = state;
                        if (!loaded.canAddToCart) {
                          context.read<ProductDetailBloc>().add(
                            const ProductAddToCartPressed(),
                          );
                          return;
                        }
                        final handler = onAddToCart;
                        if (handler != null) {
                          handler(
                            context,
                            loaded.product,
                            loaded.selectedVariant,
                          );
                          return;
                        }
                        context.read<ProductDetailBloc>().add(
                          const ProductAddToCartPressed(),
                        );
                      },
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({
    required this.product,
    required this.selectedVariantId,
    required this.relatedProducts,
    this.wishlistActionBuilder,
    this.relatedWishlistActionBuilder,
  });

  final Product product;
  final String selectedVariantId;
  final List<Product> relatedProducts;
  final Widget Function(
    BuildContext context,
    Product product,
    String? selectedVariantId,
  )?
  wishlistActionBuilder;
  final Widget Function(BuildContext context, Product product)?
  relatedWishlistActionBuilder;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProductDetailBloc>();
    final loaded = context.watch<ProductDetailBloc>().state;
    if (loaded is! ProductDetailLoaded) {
      return const SizedBox.shrink();
    }
    final variant = loaded.selectedVariant;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        ProductGallery(
          images: product.images,
          highlightedUrl: variant.imageUrl.isNotEmpty ? variant.imageUrl : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(product.name, style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          Formatters.currency(variant.price),
          style: textTheme.headlineSmall?.copyWith(color: colorScheme.primary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          variant.isInStock ? '${variant.stock} in stock' : 'Out of stock',
          style: textTheme.bodyMedium?.copyWith(
            color: variant.isInStock
                ? colorScheme.onSurfaceVariant
                : colorScheme.error,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          product.description,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        VariantSelector(
          variants: product.variants,
          selectedVariantId: selectedVariantId,
          onSelected: (id) => bloc.add(ProductVariantSelected(id)),
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child:
              wishlistActionBuilder?.call(
                context,
                product,
                selectedVariantId,
              ) ??
              const SizedBox.shrink(),
        ),
        if (relatedProducts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          Text('Related products', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 196,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: relatedProducts.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final related = relatedProducts[index];
                return SizedBox(
                  width: 148,
                  child: ProductCard(
                    product: related,
                    onTap: () =>
                        context.push(ProductRoutes.detailPath(related.id)),
                    wishlistAction: relatedWishlistActionBuilder?.call(
                      context,
                      related,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Text('Reviews', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        const _ReviewsSection(),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewsCubit, ReviewsState>(
      listenWhen: (prev, next) => next is ReviewsLoaded && next.submitSucceeded,
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Review submitted')));
        context.read<ReviewsCubit>().clearSubmitSucceeded();
      },
      builder: (context, state) {
        return switch (state) {
          ReviewsInitial() || ReviewsLoading() => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          ),
          ReviewsError(:final message) => AppErrorState(
            title: 'Could not load reviews',
            message: message,
            onRetry: () {
              final detail = context.read<ProductDetailBloc>().state;
              if (detail is ProductDetailLoaded) {
                context.read<ReviewsCubit>().load(detail.product.id);
              }
            },
          ),
          ReviewsLoaded(
            :final reviews,
            :final averageRating,
            :final isSubmitting,
            :final submitError,
          ) =>
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RatingSummary(
                  averageRating: averageRating,
                  reviewCount: reviews.length,
                ),
                const SizedBox(height: AppSpacing.lg),
                ReviewList(reviews: reviews),
                const SizedBox(height: AppSpacing.lg),
                _ReviewComposer(
                  isSubmitting: isSubmitting,
                  errorText: submitError,
                ),
              ],
            ),
        };
      },
    );
  }
}

class _ReviewComposer extends StatelessWidget {
  const _ReviewComposer({required this.isSubmitting, this.errorText});

  final bool isSubmitting;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState case AuthAuthenticated(:final session)) {
      return ReviewSubmissionForm(
        isSubmitting: isSubmitting,
        errorText: errorText,
        onSubmit: ({required rating, required title, required body}) {
          context.read<ReviewsCubit>().submit(
            userId: session.user.id,
            userDisplayName: session.user.displayName,
            rating: rating,
            title: title,
            body: body,
          );
        },
      );
    }

    return AppButton(
      label: 'Sign in to review',
      variant: AppButtonVariant.outline,
      isFullWidth: true,
      onPressed: () {
        final redirect = Uri.encodeComponent(
          GoRouterState.of(context).uri.toString(),
        );
        context.push(
          '${AuthRoutes.loginPath}?${SystemRoutes.redirectQueryKey}=$redirect',
        );
      },
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        AppShimmerPlaceholder(variant: AppShimmerVariant.card, height: 280),
        SizedBox(height: AppSpacing.lg),
        AppShimmerPlaceholder(width: 220, height: 28),
        SizedBox(height: AppSpacing.sm),
        AppShimmerPlaceholder(width: 100, height: 24),
        SizedBox(height: AppSpacing.lg),
        AppShimmerPlaceholder(height: 80),
      ],
    );
  }
}

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/featured_category.dart';
import '../../domain/entities/featured_product.dart';
import '../../domain/entities/home_banner.dart';
import '../bloc/home_bloc.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/featured_category_row.dart';
import '../widgets/featured_product_row.dart';

/// Storefront home — banners, featured categories, featured products.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.homeBloc});

  /// Optional override for tests; defaults to `getIt<HomeBloc>()`.
  final HomeBloc? homeBloc;

  /// Builds a [HomeScreen] wired to a freshly created [HomeBloc].
  static Widget provided({HomeBloc? homeBloc}) {
    return HomeScreen(homeBloc: homeBloc);
  }

  static const String categoriesPath = '/categories';

  static String productPath(String productId) => '/products/$productId';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => (homeBloc ?? getIt<HomeBloc>())..add(const HomeStarted()),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return switch (state) {
                HomeInitial() || HomeLoading() => const _HomeSkeleton(),
                HomeError(:final message) => AppErrorState(
                  title: 'Could not load home',
                  message: message,
                  onRetry: () =>
                      context.read<HomeBloc>().add(const HomeRetried()),
                ),
                HomeLoaded(:final feed) => RefreshIndicator(
                  onRefresh: () async {
                    context.read<HomeBloc>().add(const HomeRetried());
                    await context.read<HomeBloc>().stream.firstWhere(
                      (s) => s is HomeLoaded || s is HomeError,
                    );
                  },
                  child: feed.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 120),
                            AppEmptyState(
                              title: 'Nothing featured yet',
                              message:
                                  'Featured banners and products will appear '
                                  'here once the catalog is configured.',
                            ),
                          ],
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg,
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Text(
                                'Home',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            BannerCarousel(
                              banners: feed.banners,
                              onBannerTap: (banner) =>
                                  _onBannerTap(context, banner),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: FeaturedCategoryRow(
                                categories: feed.featuredCategories,
                                onCategoryTap: (category) =>
                                    _onCategoryTap(context, category),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: FeaturedProductRow(
                                products: feed.featuredProducts,
                                onProductTap: (product) =>
                                    _onProductTap(context, product),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                          ],
                        ),
                ),
              };
            },
          ),
        ),
      ),
    );
  }

  void _onBannerTap(BuildContext context, HomeBanner banner) {
    switch (banner.targetKind) {
      case HomeBannerTargetKind.category:
        context.go(categoriesPath);
      case HomeBannerTargetKind.product:
        context.push(productPath(banner.targetId));
      case HomeBannerTargetKind.external:
        context.go(categoriesPath);
    }
  }

  void _onCategoryTap(BuildContext context, FeaturedCategory category) {
    context.go(categoriesPath);
  }

  void _onProductTap(BuildContext context, FeaturedProduct product) {
    context.push(productPath(product.id));
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        AppShimmerPlaceholder(width: 120, height: 28),
        SizedBox(height: AppSpacing.lg),
        AppShimmerPlaceholder(variant: AppShimmerVariant.card, height: 168),
        SizedBox(height: AppSpacing.xl),
        AppShimmerPlaceholder(width: 160, height: 20),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppShimmerPlaceholder(
                variant: AppShimmerVariant.card,
                height: 96,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppShimmerPlaceholder(
                variant: AppShimmerVariant.card,
                height: 96,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppShimmerPlaceholder(
                variant: AppShimmerVariant.card,
                height: 96,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xl),
        AppShimmerPlaceholder(width: 180, height: 20),
        SizedBox(height: AppSpacing.md),
        AppShimmerPlaceholder(variant: AppShimmerVariant.card, height: 196),
      ],
    );
  }
}

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/product.dart';
import '../bloc/product_list_bloc.dart';
import '../routing/product_routes.dart';
import '../widgets/product_card.dart';

/// Paginated catalog listing with optional category filter.
class ProductListScreen extends StatelessWidget {
  const ProductListScreen({
    this.categoryId,
    this.listBloc,
    this.title = 'Products',
    this.header,
    this.wishlistActionBuilder,
    super.key,
  });

  final String? categoryId;

  /// Optional override for tests; defaults to `getIt<ProductListBloc>()`.
  final ProductListBloc? listBloc;

  /// App bar title (Category Detail passes the category name).
  final String title;

  /// Optional chrome above the grid (e.g. category breadcrumb / chips).
  final Widget? header;

  /// Optional per-card wishlist control (composed by the app shell).
  final Widget Function(BuildContext context, Product product)?
  wishlistActionBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          (listBloc ?? getIt<ProductListBloc>())
            ..add(ProductListStarted(categoryId: categoryId)),
      child: _ProductListView(
        title: title,
        header: header,
        wishlistActionBuilder: wishlistActionBuilder,
      ),
    );
  }
}

class _ProductListView extends StatefulWidget {
  const _ProductListView({
    required this.title,
    this.header,
    this.wishlistActionBuilder,
  });

  final String title;
  final Widget? header;
  final Widget Function(BuildContext context, Product product)?
  wishlistActionBuilder;

  @override
  State<_ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<_ProductListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      context.read<ProductListBloc>().add(const ProductListLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: BlocBuilder<ProductListBloc, ProductListState>(
        builder: (context, state) {
          return switch (state) {
            ProductListInitial() || ProductListLoading() => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.header != null) widget.header!,
                const Expanded(child: _ProductListSkeleton()),
              ],
            ),
            ProductListError(:final message) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.header != null) widget.header!,
                Expanded(
                  child: AppErrorState(
                    title: 'Could not load products',
                    message: message,
                    onRetry: () => context.read<ProductListBloc>().add(
                      const ProductListRetried(),
                    ),
                  ),
                ),
              ],
            ),
            ProductListLoaded(
              :final products,
              :final hasNextPage,
              :final isLoadingMore,
              :final loadMoreError,
              :final categoryId,
              :final totalCount,
            ) =>
              products.isEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.header != null) widget.header!,
                        Expanded(
                          child: AppEmptyState(
                            title: 'No products found',
                            message: categoryId == null
                                ? 'The catalog is empty for this store.'
                                : 'No products in this category yet.',
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        if (widget.header != null) widget.header!,
                        if (categoryId != null || totalCount != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.md,
                              AppSpacing.sm,
                              AppSpacing.md,
                              0,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                [
                                  if (categoryId != null)
                                    'Category: $categoryId',
                                  if (totalCount != null)
                                    '$totalCount products',
                                ].join(' · '),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              final crossAxisCount = width >= 900
                                  ? 4
                                  : width >= 600
                                  ? 3
                                  : 2;
                              return CustomScrollView(
                                controller: _scrollController,
                                slivers: [
                                  SliverPadding(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.md,
                                    ),
                                    sliver: SliverGrid(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: crossAxisCount,
                                            mainAxisSpacing: AppSpacing.sm,
                                            crossAxisSpacing: AppSpacing.sm,
                                            childAspectRatio: 0.68,
                                          ),
                                      delegate: SliverChildBuilderDelegate((
                                        context,
                                        index,
                                      ) {
                                        final product = products[index];
                                        return ProductCard(
                                          product: product,
                                          onTap: () => context.push(
                                            ProductRoutes.detailPath(
                                              product.id,
                                            ),
                                          ),
                                          wishlistAction: widget
                                              .wishlistActionBuilder
                                              ?.call(context, product),
                                        );
                                      }, childCount: products.length),
                                    ),
                                  ),
                                  if (isLoadingMore)
                                    const SliverToBoxAdapter(
                                      child: Padding(
                                        padding: EdgeInsets.all(AppSpacing.md),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    ),
                                  if (loadMoreError != null)
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.md,
                                        ),
                                        child: Column(
                                          children: [
                                            Text(loadMoreError),
                                            TextButton(
                                              onPressed: () => context
                                                  .read<ProductListBloc>()
                                                  .add(
                                                    const ProductListLoadMore(),
                                                  ),
                                              child: const Text('Retry'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (!hasNextPage && !isLoadingMore)
                                    const SliverToBoxAdapter(
                                      child: Padding(
                                        padding: EdgeInsets.all(AppSpacing.lg),
                                        child: Center(
                                          child: Text('End of catalog'),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
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

class _ProductListSkeleton extends StatelessWidget {
  const _ProductListSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.68,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => const AppShimmerPlaceholder(
        variant: AppShimmerVariant.card,
        height: double.infinity,
      ),
    );
  }
}

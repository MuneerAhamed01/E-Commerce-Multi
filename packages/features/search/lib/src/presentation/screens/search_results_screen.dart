import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:products/products.dart';

import '../../domain/entities/search_filter.dart';
import '../../domain/entities/sort_option.dart';
import '../bloc/search_results_bloc.dart';
import '../filter/search_filter_codec.dart';

/// Search results grid with filter/sort sheets and active filter chips.
class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({
    required this.query,
    this.initialSort = SortOption.relevance,
    this.resultsBloc,
    super.key,
  });

  final String query;
  final SortOption initialSort;

  /// Optional override for tests; defaults to `getIt<SearchResultsBloc>()`.
  final SearchResultsBloc? resultsBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          (resultsBloc ?? getIt<SearchResultsBloc>())
            ..add(SearchResultsStarted(query: query, sort: initialSort)),
      child: _SearchResultsView(query: query),
    );
  }
}

class _SearchResultsView extends StatefulWidget {
  const _SearchResultsView({required this.query});

  final String query;

  @override
  State<_SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<_SearchResultsView> {
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
      context.read<SearchResultsBloc>().add(const SearchResultsLoadMore());
    }
  }

  Future<void> _openFilters(
    BuildContext context,
    SearchFilter filter,
    Map<String, String> categoryFacets,
  ) async {
    await AppFilterBottomSheet.show(
      context,
      groups: SearchFilterCodec.buildGroups(categoryFacets: categoryFacets),
      activeFilterIds: SearchFilterCodec.toChipIds(filter),
      onApply: (ids) {
        context.read<SearchResultsBloc>().add(
          SearchResultsFilterApplied(SearchFilterCodec.fromChipIds(ids)),
        );
      },
      onClear: () {
        context.read<SearchResultsBloc>().add(
          const SearchResultsFilterCleared(),
        );
      },
    );
  }

  Future<void> _openSort(BuildContext context, SortOption selected) async {
    final next = await AppSortBottomSheet.show<SortOption>(
      context,
      options: [
        for (final option in SortOption.values)
          AppSortOption(value: option, label: option.label),
      ],
      selected: selected,
    );
    if (next != null && context.mounted) {
      context.read<SearchResultsBloc>().add(SearchResultsSortChanged(next));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.query.isEmpty ? 'Results' : '“${widget.query}”'),
        actions: [
          BlocBuilder<SearchResultsBloc, SearchResultsState>(
            builder: (context, state) {
              final filter = switch (state) {
                SearchResultsLoaded(:final filter) => filter,
                SearchResultsLoading(:final filter) => filter,
                SearchResultsError(:final filter) => filter,
                _ => SearchFilter.empty,
              };
              final sort = switch (state) {
                SearchResultsLoaded(:final sort) => sort,
                SearchResultsLoading(:final sort) => sort,
                SearchResultsError(:final sort) => sort,
                _ => SortOption.relevance,
              };
              final facets = switch (state) {
                SearchResultsLoaded(:final categoryFacets) => categoryFacets,
                SearchResultsLoading(:final categoryFacets) => categoryFacets,
                SearchResultsError(:final categoryFacets) => categoryFacets,
                _ => const <String, String>{},
              };
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Filter',
                    icon: Icon(
                      filter.hasActiveFilters
                          ? Icons.filter_alt
                          : Icons.filter_alt_outlined,
                    ),
                    onPressed: () => _openFilters(context, filter, facets),
                  ),
                  IconButton(
                    tooltip: 'Sort',
                    icon: const Icon(Icons.sort),
                    onPressed: () => _openSort(context, sort),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<SearchResultsBloc, SearchResultsState>(
        builder: (context, state) {
          return switch (state) {
            SearchResultsInitial() || SearchResultsLoading() => const Center(
              child: AppLoadingIndicator(),
            ),
            SearchResultsError(:final message) => AppErrorState(
              title: 'Could not load results',
              message: message,
              onRetry: () => context.read<SearchResultsBloc>().add(
                const SearchResultsRetried(),
              ),
            ),
            SearchResultsLoaded(
              :final products,
              :final filter,
              :final categoryFacets,
              :final hasNextPage,
              :final isLoadingMore,
              :final loadMoreError,
              :final totalCount,
            ) =>
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      0,
                    ),
                    child: AppActiveFilterChipRow(
                      filters: SearchFilterCodec.toActiveFilters(
                        filter,
                        categoryFacets: categoryFacets,
                      ),
                      onRemove: (id) => context.read<SearchResultsBloc>().add(
                        SearchResultsFilterChipRemoved(id),
                      ),
                      onClearAll: filter.hasActiveFilters
                          ? () => context.read<SearchResultsBloc>().add(
                              const SearchResultsFilterCleared(),
                            )
                          : null,
                    ),
                  ),
                  if (totalCount != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        0,
                      ),
                      child: Text(
                        '$totalCount result${totalCount == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  Expanded(
                    child: products.isEmpty
                        ? AppEmptyState(
                            title: 'No results',
                            message: filter.hasActiveFilters
                                ? 'Nothing matched these filters. '
                                      'Clear filters to broaden your search.'
                                : 'Nothing matched “${widget.query}”. '
                                      'Try another term.',
                            ctaLabel: filter.hasActiveFilters
                                ? 'Clear filters'
                                : 'Back to search',
                            onCtaPressed: filter.hasActiveFilters
                                ? () => context.read<SearchResultsBloc>().add(
                                    const SearchResultsFilterCleared(),
                                  )
                                : () => context.pop(),
                          )
                        : CustomScrollView(
                            controller: _scrollController,
                            slivers: [
                              SliverPadding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                sliver: SliverLayoutBuilder(
                                  builder: (context, constraints) {
                                    final width = constraints.crossAxisExtent;
                                    final crossAxisCount = width >= 900
                                        ? 4
                                        : width >= 600
                                        ? 3
                                        : 2;
                                    return SliverGrid(
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
                                        );
                                      }, childCount: products.length),
                                    );
                                  },
                                ),
                              ),
                              if (isLoadingMore)
                                const SliverToBoxAdapter(
                                  child: AppPaginationLoader(),
                                ),
                              if (loadMoreError != null)
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.md,
                                    ),
                                    child: AppInlineErrorBanner(
                                      message: loadMoreError,
                                    ),
                                  ),
                                ),
                              if (!hasNextPage && products.isNotEmpty)
                                const SliverToBoxAdapter(
                                  child: SizedBox(height: AppSpacing.lg),
                                ),
                            ],
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

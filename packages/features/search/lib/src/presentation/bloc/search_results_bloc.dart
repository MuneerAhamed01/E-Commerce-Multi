import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:products/products.dart';

import '../../domain/entities/search_filter.dart';
import '../../domain/entities/sort_option.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/usecases/search_products.dart';
import '../filter/search_filter_codec.dart';

part 'search_results_event.dart';
part 'search_results_state.dart';

/// Paginated search results with filter/sort composition.
final class SearchResultsBloc
    extends Bloc<SearchResultsEvent, SearchResultsState> {
  SearchResultsBloc({
    required this.searchProducts,
    required this.searchRepository,
  }) : super(const SearchResultsInitial()) {
    on<SearchResultsStarted>(_onStarted);
    on<SearchResultsRetried>(_onRetried);
    on<SearchResultsLoadMore>(_onLoadMore);
    on<SearchResultsFilterApplied>(_onFilterApplied);
    on<SearchResultsSortChanged>(_onSortChanged);
    on<SearchResultsFilterCleared>(_onFilterCleared);
    on<SearchResultsFilterChipRemoved>(_onFilterChipRemoved);
  }

  final SearchProducts searchProducts;
  final SearchRepository searchRepository;

  String _query = '';
  SearchFilter _filter = SearchFilter.empty;
  SortOption _sort = SortOption.relevance;
  String? _nextCursor;
  Map<String, String> _categoryFacets = const {};

  Future<void> _onStarted(
    SearchResultsStarted event,
    Emitter<SearchResultsState> emit,
  ) async {
    _query = event.query.trim();
    _filter = event.filter;
    _sort = event.sort;
    await _ensureFacets();
    await _loadFirstPage(emit);
  }

  Future<void> _onRetried(
    SearchResultsRetried event,
    Emitter<SearchResultsState> emit,
  ) async {
    await _ensureFacets();
    await _loadFirstPage(emit);
  }

  Future<void> _onFilterApplied(
    SearchResultsFilterApplied event,
    Emitter<SearchResultsState> emit,
  ) async {
    _filter = event.filter;
    await _loadFirstPage(emit);
  }

  Future<void> _onSortChanged(
    SearchResultsSortChanged event,
    Emitter<SearchResultsState> emit,
  ) async {
    _sort = event.sort;
    await _loadFirstPage(emit);
  }

  Future<void> _onFilterCleared(
    SearchResultsFilterCleared event,
    Emitter<SearchResultsState> emit,
  ) async {
    _filter = SearchFilter.empty;
    await _loadFirstPage(emit);
  }

  Future<void> _onFilterChipRemoved(
    SearchResultsFilterChipRemoved event,
    Emitter<SearchResultsState> emit,
  ) async {
    _filter = SearchFilterCodec.removeChip(_filter, event.chipId);
    await _loadFirstPage(emit);
  }

  Future<void> _ensureFacets() async {
    if (_categoryFacets.isNotEmpty) {
      return;
    }
    final result = await searchRepository.getCategoryFacets();
    result.fold(
      onFailure: (_) {},
      onSuccess: (facets) => _categoryFacets = facets,
    );
  }

  Future<void> _loadFirstPage(Emitter<SearchResultsState> emit) async {
    emit(
      SearchResultsLoading(
        query: _query,
        filter: _filter,
        sort: _sort,
        categoryFacets: _categoryFacets,
      ),
    );
    _nextCursor = null;
    final result = await searchProducts(
      SearchProductsParams(
        query: _query,
        filter: _filter,
        sort: _sort,
        page: const ProductPageRequest(),
      ),
    );
    result.fold(
      onFailure: (failure) => emit(
        SearchResultsError(
          message: _mapFailure(failure),
          query: _query,
          filter: _filter,
          sort: _sort,
          categoryFacets: _categoryFacets,
        ),
      ),
      onSuccess: (page) {
        _nextCursor = page.nextPageCursor;
        emit(
          SearchResultsLoaded(
            query: _query,
            filter: _filter,
            sort: _sort,
            products: page.items,
            hasNextPage: page.hasNextPage,
            categoryFacets: _categoryFacets,
            totalCount: page.totalCount,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMore(
    SearchResultsLoadMore event,
    Emitter<SearchResultsState> emit,
  ) async {
    final current = state;
    if (current is! SearchResultsLoaded) {
      return;
    }
    if (!current.hasNextPage || current.isLoadingMore || _nextCursor == null) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true, clearLoadMoreError: true));
    final result = await searchProducts(
      SearchProductsParams(
        query: _query,
        filter: _filter,
        sort: _sort,
        page: ProductPageRequest(cursor: _nextCursor),
      ),
    );
    result.fold(
      onFailure: (failure) => emit(
        current.copyWith(
          isLoadingMore: false,
          loadMoreError: _mapFailure(failure),
        ),
      ),
      onSuccess: (page) {
        _nextCursor = page.nextPageCursor;
        emit(
          SearchResultsLoaded(
            query: _query,
            filter: _filter,
            sort: _sort,
            products: [...current.products, ...page.items],
            hasNextPage: page.hasNextPage,
            categoryFacets: _categoryFacets,
            totalCount: page.totalCount,
          ),
        );
      },
    );
  }

  String _mapFailure(Failure failure) {
    return failure.message ??
        'Unable to load search results. Please try again.';
  }
}

part of 'search_results_bloc.dart';

sealed class SearchResultsState extends Equatable {
  const SearchResultsState();

  @override
  List<Object?> get props => [];
}

final class SearchResultsInitial extends SearchResultsState {
  const SearchResultsInitial();
}

final class SearchResultsLoading extends SearchResultsState {
  const SearchResultsLoading({
    required this.query,
    required this.filter,
    required this.sort,
    this.categoryFacets = const {},
  });

  final String query;
  final SearchFilter filter;
  final SortOption sort;
  final Map<String, String> categoryFacets;

  @override
  List<Object?> get props => [query, filter, sort, categoryFacets];
}

final class SearchResultsLoaded extends SearchResultsState {
  const SearchResultsLoaded({
    required this.query,
    required this.filter,
    required this.sort,
    required this.products,
    required this.hasNextPage,
    required this.categoryFacets,
    this.totalCount,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final String query;
  final SearchFilter filter;
  final SortOption sort;
  final List<Product> products;
  final bool hasNextPage;
  final Map<String, String> categoryFacets;
  final int? totalCount;
  final bool isLoadingMore;
  final String? loadMoreError;

  bool get isEmpty => products.isEmpty;

  SearchResultsLoaded copyWith({
    String? query,
    SearchFilter? filter,
    SortOption? sort,
    List<Product>? products,
    bool? hasNextPage,
    Map<String, String>? categoryFacets,
    int? totalCount,
    bool? isLoadingMore,
    String? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return SearchResultsLoaded(
      query: query ?? this.query,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      products: products ?? this.products,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      categoryFacets: categoryFacets ?? this.categoryFacets,
      totalCount: totalCount ?? this.totalCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: clearLoadMoreError
          ? null
          : (loadMoreError ?? this.loadMoreError),
    );
  }

  @override
  List<Object?> get props => [
    query,
    filter,
    sort,
    products,
    hasNextPage,
    categoryFacets,
    totalCount,
    isLoadingMore,
    loadMoreError,
  ];
}

final class SearchResultsError extends SearchResultsState {
  const SearchResultsError({
    required this.message,
    required this.query,
    required this.filter,
    required this.sort,
    this.categoryFacets = const {},
  });

  final String message;
  final String query;
  final SearchFilter filter;
  final SortOption sort;
  final Map<String, String> categoryFacets;

  @override
  List<Object?> get props => [message, query, filter, sort, categoryFacets];
}

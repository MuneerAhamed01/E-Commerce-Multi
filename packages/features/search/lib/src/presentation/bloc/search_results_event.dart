part of 'search_results_bloc.dart';

sealed class SearchResultsEvent extends Equatable {
  const SearchResultsEvent();

  @override
  List<Object?> get props => [];
}

final class SearchResultsStarted extends SearchResultsEvent {
  const SearchResultsStarted({
    required this.query,
    this.filter = SearchFilter.empty,
    this.sort = SortOption.relevance,
  });

  final String query;
  final SearchFilter filter;
  final SortOption sort;

  @override
  List<Object?> get props => [query, filter, sort];
}

final class SearchResultsRetried extends SearchResultsEvent {
  const SearchResultsRetried();
}

final class SearchResultsLoadMore extends SearchResultsEvent {
  const SearchResultsLoadMore();
}

final class SearchResultsFilterApplied extends SearchResultsEvent {
  const SearchResultsFilterApplied(this.filter);

  final SearchFilter filter;

  @override
  List<Object?> get props => [filter];
}

final class SearchResultsSortChanged extends SearchResultsEvent {
  const SearchResultsSortChanged(this.sort);

  final SortOption sort;

  @override
  List<Object?> get props => [sort];
}

final class SearchResultsFilterCleared extends SearchResultsEvent {
  const SearchResultsFilterCleared();
}

final class SearchResultsFilterChipRemoved extends SearchResultsEvent {
  const SearchResultsFilterChipRemoved(this.chipId);

  final String chipId;

  @override
  List<Object?> get props => [chipId];
}

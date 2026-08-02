part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

final class SearchStarted extends SearchEvent {
  const SearchStarted();
}

/// Fired after presentation debounce (≥300ms via [AppSearchBar]).
final class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class SearchSubmitted extends SearchEvent {
  const SearchSubmitted(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class SearchRecentCleared extends SearchEvent {
  const SearchRecentCleared();
}

final class SearchRetried extends SearchEvent {
  const SearchRetried();
}

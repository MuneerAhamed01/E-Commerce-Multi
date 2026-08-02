part of 'search_bloc.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

final class SearchInitial extends SearchState {
  const SearchInitial();
}

final class SearchEntryLoaded extends SearchState {
  const SearchEntryLoaded({
    required this.query,
    required this.recentSearches,
    required this.trendingTerms,
    this.suggestions = const [],
    this.isSuggesting = false,
    this.suggestionsError,
  });

  final String query;
  final List<String> recentSearches;
  final List<String> trendingTerms;
  final List<SearchSuggestion> suggestions;
  final bool isSuggesting;
  final String? suggestionsError;

  bool get showSuggestions => query.trim().isNotEmpty;

  SearchEntryLoaded copyWith({
    String? query,
    List<String>? recentSearches,
    List<String>? trendingTerms,
    List<SearchSuggestion>? suggestions,
    bool? isSuggesting,
    String? suggestionsError,
    bool clearSuggestionsError = false,
  }) {
    return SearchEntryLoaded(
      query: query ?? this.query,
      recentSearches: recentSearches ?? this.recentSearches,
      trendingTerms: trendingTerms ?? this.trendingTerms,
      suggestions: suggestions ?? this.suggestions,
      isSuggesting: isSuggesting ?? this.isSuggesting,
      suggestionsError: clearSuggestionsError
          ? null
          : (suggestionsError ?? this.suggestionsError),
    );
  }

  @override
  List<Object?> get props => [
    query,
    recentSearches,
    trendingTerms,
    suggestions,
    isSuggesting,
    suggestionsError,
  ];
}

final class SearchEntryError extends SearchState {
  const SearchEntryError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Side-effect signal: navigate to results for [query].
final class SearchNavigateToResults extends SearchState {
  const SearchNavigateToResults(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

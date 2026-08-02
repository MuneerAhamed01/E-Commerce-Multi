import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/mock/trending_terms.dart';
import '../../domain/entities/search_suggestion.dart';
import '../../domain/usecases/clear_recent_searches.dart';
import '../../domain/usecases/get_recent_searches.dart';
import '../../domain/usecases/get_search_suggestions.dart';
import '../../domain/usecases/save_recent_search.dart';

part 'search_event.dart';
part 'search_state.dart';

/// Search entry screen: recent/trending + debounced suggestions.
///
/// Debounce (≥300ms) is a **presentation** concern handled by
/// [AppSearchBar] before [SearchQueryChanged] is dispatched.
final class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required this.getSearchSuggestions,
    required this.getRecentSearches,
    required this.saveRecentSearch,
    required this.clearRecentSearches,
  }) : super(const SearchInitial()) {
    on<SearchStarted>(_onStarted);
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchSubmitted>(_onSubmitted);
    on<SearchRecentCleared>(_onRecentCleared);
    on<SearchRetried>(_onRetried);
  }

  final GetSearchSuggestions getSearchSuggestions;
  final GetRecentSearches getRecentSearches;
  final SaveRecentSearch saveRecentSearch;
  final ClearRecentSearches clearRecentSearches;

  Future<void> _onStarted(
    SearchStarted event,
    Emitter<SearchState> emit,
  ) async {
    final result = await getRecentSearches(const NoParams());
    result.fold(
      onFailure: (failure) => emit(SearchEntryError(_mapFailure(failure))),
      onSuccess: (recent) => emit(
        SearchEntryLoaded(
          query: '',
          recentSearches: recent,
          trendingTerms: TrendingTerms.all,
        ),
      ),
    );
  }

  Future<void> _onRetried(
    SearchRetried event,
    Emitter<SearchState> emit,
  ) async {
    await _onStarted(const SearchStarted(), emit);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final current = state;
    if (current is! SearchEntryLoaded) {
      return;
    }

    final query = event.query;
    if (query.trim().isEmpty) {
      emit(
        current.copyWith(
          query: query,
          suggestions: const [],
          isSuggesting: false,
          clearSuggestionsError: true,
        ),
      );
      return;
    }

    emit(
      current.copyWith(
        query: query,
        isSuggesting: true,
        clearSuggestionsError: true,
      ),
    );

    final result = await getSearchSuggestions(
      GetSearchSuggestionsParams(query),
    );
    if (state is! SearchEntryLoaded) {
      return;
    }
    final latest = state as SearchEntryLoaded;
    // Drop stale responses if the user kept typing.
    if (latest.query != query) {
      return;
    }

    result.fold(
      onFailure: (failure) => emit(
        latest.copyWith(
          isSuggesting: false,
          suggestionsError: _mapFailure(failure),
        ),
      ),
      onSuccess: (suggestions) => emit(
        latest.copyWith(
          suggestions: suggestions,
          isSuggesting: false,
          clearSuggestionsError: true,
        ),
      ),
    );
  }

  Future<void> _onSubmitted(
    SearchSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      return;
    }

    await saveRecentSearch(SaveRecentSearchParams(query));
    final recentResult = await getRecentSearches(const NoParams());
    final recent = recentResult.fold(
      onFailure: (_) => const <String>[],
      onSuccess: (value) => value,
    );

    final current = state;
    if (current is SearchEntryLoaded) {
      emit(current.copyWith(query: query, recentSearches: recent));
    }

    emit(SearchNavigateToResults(query));

    if (current is SearchEntryLoaded) {
      emit(
        SearchEntryLoaded(
          query: query,
          recentSearches: recent,
          trendingTerms: current.trendingTerms,
          suggestions: current.suggestions,
        ),
      );
    }
  }

  Future<void> _onRecentCleared(
    SearchRecentCleared event,
    Emitter<SearchState> emit,
  ) async {
    final current = state;
    if (current is! SearchEntryLoaded) {
      return;
    }
    await clearRecentSearches(const NoParams());
    emit(current.copyWith(recentSearches: const []));
  }

  String _mapFailure(Failure failure) {
    return failure.message ??
        'Unable to load search right now. Please try again.';
  }
}

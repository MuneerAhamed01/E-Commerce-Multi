import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/mock_search_remote_data_source.dart';
import '../data/datasources/recent_search_local_data_source.dart';
import '../data/datasources/search_remote_data_source.dart';
import '../data/repositories/mock_search_repository_impl.dart';
import '../data/repositories/recent_search_repository_impl.dart';
import '../domain/repositories/recent_search_repository.dart';
import '../domain/repositories/search_repository.dart';
import '../domain/usecases/clear_recent_searches.dart';
import '../domain/usecases/get_recent_searches.dart';
import '../domain/usecases/get_search_suggestions.dart';
import '../domain/usecases/save_recent_search.dart';
import '../domain/usecases/search_products.dart';
import '../presentation/bloc/search_bloc.dart';
import '../presentation/bloc/search_results_bloc.dart';

/// Registers search data/domain/presentation dependencies.
///
/// Call **after** [configureMockInjection] (and after auth so
/// [SharedPreferences] exists). Products injection is optional — search
/// maps [MockSeedStore] via the products catalog builder internally.
/// Safe to call once per process.
void configureSearchInjection() {
  if (!getIt.isRegistered<MockNetworkSimulator>() ||
      !getIt.isRegistered<MockSeedStore>() ||
      !getIt.isRegistered<MockDeveloperControls>()) {
    throw StateError(
      'configureSearchInjection() requires configureMockInjection() first.',
    );
  }
  if (!getIt.isRegistered<SharedPreferences>()) {
    throw StateError(
      'configureSearchInjection() requires SharedPreferences '
      '(configureAuthenticationInjection) first.',
    );
  }

  if (!getIt.isRegistered<SearchRemoteDataSource>()) {
    getIt.registerLazySingleton<SearchRemoteDataSource>(
      () => MockSearchRemoteDataSource(
        simulator: getIt<MockNetworkSimulator>(),
        store: getIt<MockSeedStore>(),
        controls: getIt<MockDeveloperControls>(),
      ),
    );
  }

  if (!getIt.isRegistered<SearchRepository>()) {
    getIt.registerLazySingleton<SearchRepository>(
      () => MockSearchRepositoryImpl(remote: getIt<SearchRemoteDataSource>()),
    );
  }

  if (!getIt.isRegistered<RecentSearchLocalDataSource>()) {
    getIt.registerLazySingleton<RecentSearchLocalDataSource>(
      () => SharedPreferencesRecentSearchLocalDataSource(
        getIt<SharedPreferences>(),
      ),
    );
  }

  if (!getIt.isRegistered<RecentSearchRepository>()) {
    getIt.registerLazySingleton<RecentSearchRepository>(
      () => RecentSearchRepositoryImpl(
        local: getIt<RecentSearchLocalDataSource>(),
      ),
    );
  }

  _registerFactory<SearchProducts>(() => SearchProducts(getIt()));
  _registerFactory<GetSearchSuggestions>(() => GetSearchSuggestions(getIt()));
  _registerFactory<GetRecentSearches>(() => GetRecentSearches(getIt()));
  _registerFactory<SaveRecentSearch>(() => SaveRecentSearch(getIt()));
  _registerFactory<ClearRecentSearches>(() => ClearRecentSearches(getIt()));

  _registerFactory<SearchBloc>(
    () => SearchBloc(
      getSearchSuggestions: getIt(),
      getRecentSearches: getIt(),
      saveRecentSearch: getIt(),
      clearRecentSearches: getIt(),
    ),
  );
  _registerFactory<SearchResultsBloc>(
    () => SearchResultsBloc(searchProducts: getIt(), searchRepository: getIt()),
  );
}

void _registerFactory<T extends Object>(T Function() factory) {
  if (!getIt.isRegistered<T>()) {
    getIt.registerFactory<T>(factory);
  }
}

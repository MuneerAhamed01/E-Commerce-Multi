import 'dart:math';

import 'package:core/core.dart';
import 'package:search/search.dart';
import 'package:search/src/data/datasources/mock_search_remote_data_source.dart';
import 'package:search/src/data/datasources/recent_search_local_data_source.dart';
import 'package:search/src/data/repositories/mock_search_repository_impl.dart';
import 'package:search/src/data/repositories/recent_search_repository_impl.dart';

final class SearchTestHarness {
  SearchTestHarness._({
    required this.controls,
    required this.store,
    required this.searchRepository,
    required this.recentRepository,
    required this.searchProducts,
    required this.getSearchSuggestions,
    required this.getRecentSearches,
    required this.saveRecentSearch,
    required this.clearRecentSearches,
    required this.localRecent,
  });

  final MockDeveloperControls controls;
  final MockSeedStore store;
  final SearchRepository searchRepository;
  final RecentSearchRepository recentRepository;
  final SearchProducts searchProducts;
  final GetSearchSuggestions getSearchSuggestions;
  final GetRecentSearches getRecentSearches;
  final SaveRecentSearch saveRecentSearch;
  final ClearRecentSearches clearRecentSearches;
  final InMemoryRecentSearchLocalDataSource localRecent;

  static SearchTestHarness create({List<String>? recentSeed}) {
    final controls = MockDeveloperControls()..latencyDisabled = true;
    final store = MockSeedStore(controls: controls);
    final simulator = MockNetworkSimulator(
      appConfig: const AppConfig(
        environment: Environment.dev,
        dataSourceMode: DataSourceMode.mock,
        logLevel: LogLevel.debug,
        mockLatencyMin: Duration.zero,
        mockLatencyMax: Duration.zero,
        isDeveloperModeAvailable: true,
      ),
      controls: controls,
      random: Random(0),
    );
    final remote = MockSearchRemoteDataSource(
      simulator: simulator,
      store: store,
      controls: controls,
    );
    final searchRepository = MockSearchRepositoryImpl(remote: remote);
    final localRecent = InMemoryRecentSearchLocalDataSource(seed: recentSeed);
    final recentRepository = RecentSearchRepositoryImpl(local: localRecent);

    return SearchTestHarness._(
      controls: controls,
      store: store,
      searchRepository: searchRepository,
      recentRepository: recentRepository,
      searchProducts: SearchProducts(searchRepository),
      getSearchSuggestions: GetSearchSuggestions(searchRepository),
      getRecentSearches: GetRecentSearches(recentRepository),
      saveRecentSearch: SaveRecentSearch(recentRepository),
      clearRecentSearches: ClearRecentSearches(recentRepository),
      localRecent: localRecent,
    );
  }

  SearchBloc createSearchBloc() => SearchBloc(
    getSearchSuggestions: getSearchSuggestions,
    getRecentSearches: getRecentSearches,
    saveRecentSearch: saveRecentSearch,
    clearRecentSearches: clearRecentSearches,
  );

  SearchResultsBloc createResultsBloc() => SearchResultsBloc(
    searchProducts: searchProducts,
    searchRepository: searchRepository,
  );
}

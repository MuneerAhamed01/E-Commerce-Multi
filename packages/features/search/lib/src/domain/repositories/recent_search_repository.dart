import 'package:core/core.dart';

/// Local-only recent search terms (SharedPreferences-backed in mock/dev).
abstract interface class RecentSearchRepository {
  Future<Result<Failure, List<String>>> getRecentSearches();

  Future<Result<Failure, void>> saveRecentSearch(String query);

  Future<Result<Failure, void>> clearRecentSearches();
}

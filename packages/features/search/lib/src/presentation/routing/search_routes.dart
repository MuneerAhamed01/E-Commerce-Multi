/// Named path helpers for search screens (docs/09_ROUTING_PLAN.md).
abstract final class SearchRoutes {
  static const String entryPath = '/search';
  static const String entryName = 'SearchRoute';

  static const String resultsPath = '/search/results';
  static const String resultsName = 'SearchResultsRoute';

  static const String queryKey = 'q';
  static const String sortKey = 'sort';

  static String resultsPathForQuery(String query) {
    final encoded = Uri.encodeQueryComponent(query.trim());
    return '$resultsPath?$queryKey=$encoded';
  }

  static String resultsLocation({required String query, String? sort}) {
    final params = <String, String>{queryKey: query.trim()};
    if (sort != null && sort.isNotEmpty) {
      params[sortKey] = sort;
    }
    return Uri(path: resultsPath, queryParameters: params).toString();
  }
}

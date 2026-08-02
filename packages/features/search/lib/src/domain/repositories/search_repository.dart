import 'package:core/core.dart';
import 'package:products/products.dart';

import '../entities/search_filter.dart';
import '../entities/search_suggestion.dart';
import '../entities/sort_option.dart';

/// Search catalog contract (docs/10_DATA_FLOW.md / Phase 11).
abstract interface class SearchRepository {
  Future<Result<Failure, PaginatedResult<Product>>> searchProducts({
    required String query,
    required SearchFilter filter,
    required SortOption sort,
    required ProductPageRequest page,
  });

  Future<Result<Failure, List<SearchSuggestion>>> getSuggestions(String query);

  /// Top-level category facets for the filter sheet (id → label).
  Future<Result<Failure, Map<String, String>>> getCategoryFacets();
}

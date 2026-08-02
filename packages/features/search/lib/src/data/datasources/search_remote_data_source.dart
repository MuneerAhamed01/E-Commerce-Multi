import 'package:core/core.dart';
import 'package:products/products.dart';

import '../../domain/entities/search_filter.dart';
import '../../domain/entities/search_suggestion.dart';
import '../../domain/entities/sort_option.dart';

/// Remote (mock) search API surface.
abstract interface class SearchRemoteDataSource {
  Future<PaginatedResult<Product>> searchProducts({
    required String query,
    required SearchFilter filter,
    required SortOption sort,
    required ProductPageRequest page,
  });

  Future<List<SearchSuggestion>> fetchSuggestions(String query);

  Future<Map<String, String>> fetchCategoryFacets();
}

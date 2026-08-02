import 'dart:convert';

import 'package:core/core.dart';
import 'package:products/products.dart';

import '../../domain/entities/search_filter.dart';
import '../../domain/entities/search_suggestion.dart';
import '../../domain/entities/sort_option.dart';
import '../mock/search_call_types.dart';
import '../mock/search_matcher.dart';
import '../mock/search_product_mapper.dart';
import 'search_remote_data_source.dart';

/// In-memory search over [MockSeedStore] products.
final class MockSearchRemoteDataSource
    with MockDataSourceMixin
    implements SearchRemoteDataSource {
  MockSearchRemoteDataSource({
    required this.simulator,
    required MockSeedStore store,
    required MockDeveloperControls controls,
    // ignore: prefer_initializing_formals
  }) : _store = store,
       // ignore: prefer_initializing_formals
       _controls = controls {
    _rebuildCatalog();
    _controls.registerResetListener(_onReset);
  }

  @override
  final MockNetworkSimulator simulator;

  final MockSeedStore _store;
  final MockDeveloperControls _controls;

  late List<Product> _orderedProducts;
  late Map<String, String> _categoryNames;

  void dispose() {
    _controls.unregisterResetListener(_onReset);
  }

  void _onReset() {
    _rebuildCatalog();
  }

  void _rebuildCatalog() {
    _orderedProducts = _store.products
        .map(SearchProductMapper.fromSeed)
        .toList(growable: false);
    _categoryNames = {
      for (final category in _store.categories) category.id: category.name,
    };
  }

  @override
  Future<PaginatedResult<Product>> searchProducts({
    required String query,
    required SearchFilter filter,
    required SortOption sort,
    required ProductPageRequest page,
  }) {
    return guarded(SearchCallTypes.search, () async {
      final matched = SearchMatcher.apply(
        source: _orderedProducts,
        query: query,
        filter: filter,
        sort: sort,
      );
      return _paginate(matched, page);
    });
  }

  @override
  Future<List<SearchSuggestion>> fetchSuggestions(String query) {
    return guarded(SearchCallTypes.suggestions, () async {
      return SearchMatcher.buildSuggestions(
        products: _orderedProducts,
        categoryNames: _categoryNames,
        rawQuery: query,
      );
    });
  }

  @override
  Future<Map<String, String>> fetchCategoryFacets() {
    return guarded(SearchCallTypes.facets, () async {
      final roots = _store.categories.where((c) => c.parentId == null).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return {for (final category in roots) category.id: category.name};
    });
  }

  PaginatedResult<Product> _paginate(
    List<Product> items,
    ProductPageRequest page,
  ) {
    final start = _decodeCursor(page.cursor);
    if (start < 0 || start > items.length) {
      throw const ValidationException({
        'cursor': 'Invalid page cursor',
      }, 'Invalid cursor');
    }
    final end = (start + page.pageSize).clamp(0, items.length);
    final slice = items.sublist(start, end);
    final next = end < items.length ? _encodeCursor(end) : null;
    return PaginatedResult<Product>(
      items: slice,
      nextPageCursor: next,
      totalCount: items.length,
    );
  }

  static String _encodeCursor(int nextIndex) {
    final payload = jsonEncode({'i': nextIndex});
    return base64Url.encode(utf8.encode(payload));
  }

  static int _decodeCursor(String? cursor) {
    if (cursor == null || cursor.isEmpty) {
      return 0;
    }
    try {
      final decoded = utf8.decode(base64Url.decode(cursor));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      return (map['i'] as num).toInt();
    } on Object {
      throw const ValidationException({
        'cursor': 'Invalid page cursor',
      }, 'Invalid cursor');
    }
  }
}

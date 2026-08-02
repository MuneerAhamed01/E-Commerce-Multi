import 'package:products/products.dart';

import '../../domain/entities/search_filter.dart';
import '../../domain/entities/search_suggestion.dart';
import '../../domain/entities/sort_option.dart';

/// Pure matching / filter / sort helpers for mock search (unit-tested).
///
/// **Filter semantics:** every non-empty field on [SearchFilter] is ANDed.
/// **Debounce:** not applied here — presentation (`AppSearchBar`, ≥300ms)
/// debounces suggestion requests before they reach this layer.
abstract final class SearchMatcher {
  static bool matchesQuery(Product product, String rawQuery) {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return true;
    }
    final name = product.name.toLowerCase();
    final description = product.description.toLowerCase();
    return name.contains(query) || description.contains(query);
  }

  /// Returns true when [product] satisfies every active filter field (AND).
  static bool matchesFilter(Product product, SearchFilter filter) {
    if (filter.isEmpty) {
      return true;
    }

    final categoryId = filter.categoryId;
    if (categoryId != null &&
        categoryId.isNotEmpty &&
        product.categoryId != categoryId) {
      return false;
    }

    final minRating = filter.minRating;
    if (minRating != null && product.rating < minRating) {
      return false;
    }

    if (filter.inStockOnly &&
        !product.variants.any((variant) => variant.isInStock)) {
      return false;
    }

    final price = product.cheapestVariant.price.minorUnits;
    final minPrice = filter.minPriceMinor;
    if (minPrice != null && price < minPrice) {
      return false;
    }
    final maxPrice = filter.maxPriceMinor;
    if (maxPrice != null && price > maxPrice) {
      return false;
    }

    return true;
  }

  static List<Product> apply({
    required List<Product> source,
    required String query,
    required SearchFilter filter,
    required SortOption sort,
  }) {
    final matched = source
        .where(
          (product) =>
              matchesQuery(product, query) && matchesFilter(product, filter),
        )
        .toList(growable: true);
    sortProducts(matched, query: query, sort: sort);
    return matched;
  }

  static void sortProducts(
    List<Product> products, {
    required String query,
    required SortOption sort,
  }) {
    final normalized = query.trim().toLowerCase();
    products.sort((a, b) {
      switch (sort) {
        case SortOption.relevance:
          final scoreCmp = _relevanceScore(
            b,
            normalized,
          ).compareTo(_relevanceScore(a, normalized));
          if (scoreCmp != 0) {
            return scoreCmp;
          }
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case SortOption.priceAsc:
          return a.cheapestVariant.price.minorUnits.compareTo(
            b.cheapestVariant.price.minorUnits,
          );
        case SortOption.priceDesc:
          return b.cheapestVariant.price.minorUnits.compareTo(
            a.cheapestVariant.price.minorUnits,
          );
        case SortOption.newest:
          // Seed catalog ids increase with generation order (`prod_001`…).
          return _numericSuffix(b.id).compareTo(_numericSuffix(a.id));
        case SortOption.rating:
          final ratingCmp = b.rating.compareTo(a.rating);
          if (ratingCmp != 0) {
            return ratingCmp;
          }
          return b.reviewCount.compareTo(a.reviewCount);
      }
    });
  }

  static List<SearchSuggestion> buildSuggestions({
    required List<Product> products,
    required Map<String, String> categoryNames,
    required String rawQuery,
    int limit = 8,
  }) {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return const [];
    }

    final suggestions = <SearchSuggestion>[];
    final seenTitles = <String>{};

    for (final product in products) {
      if (!matchesQuery(product, query)) {
        continue;
      }
      final key = product.name.toLowerCase();
      if (!seenTitles.add(key)) {
        continue;
      }
      suggestions.add(
        SearchSuggestion(
          id: 'product_${product.id}',
          title: product.name,
          kind: SearchSuggestionKind.product,
          subtitle: categoryNames[product.categoryId],
          productId: product.id,
          queryText: product.name,
        ),
      );
      if (suggestions.length >= limit) {
        return suggestions;
      }
    }

    // Query completions from distinct name tokens that start with the query.
    for (final product in products) {
      for (final token in product.name.toLowerCase().split(RegExp(r'\s+'))) {
        if (token.length < 3 || !token.startsWith(query)) {
          continue;
        }
        if (!seenTitles.add(token)) {
          continue;
        }
        suggestions.add(
          SearchSuggestion(
            id: 'completion_$token',
            title: token,
            kind: SearchSuggestionKind.queryCompletion,
            queryText: token,
          ),
        );
        if (suggestions.length >= limit) {
          return suggestions;
        }
      }
    }

    return suggestions;
  }

  static int _relevanceScore(Product product, String query) {
    if (query.isEmpty) {
      return 0;
    }
    final name = product.name.toLowerCase();
    if (name == query) {
      return 300;
    }
    if (name.startsWith(query)) {
      return 200;
    }
    if (name.contains(query)) {
      return 100;
    }
    if (product.description.toLowerCase().contains(query)) {
      return 50;
    }
    return 0;
  }

  static int _numericSuffix(String id) {
    final match = RegExp(r'(\d+)$').firstMatch(id);
    if (match == null) {
      return 0;
    }
    return int.tryParse(match.group(1)!) ?? 0;
  }
}

import 'package:design_system/design_system.dart';

import '../../domain/entities/search_filter.dart';

/// Encodes [SearchFilter] ↔ filter-sheet chip ids / active chip labels.
///
/// Chip id prefixes:
/// - `cat:{categoryId}`
/// - `rating:{n}` (min rating)
/// - `stock:in`
/// - `price:{minMinor}-{maxMinor|max}`
abstract final class SearchFilterCodec {
  static const String stockInId = 'stock:in';

  static const List<(String id, String label, int? min, int? max)>
  priceBuckets = [
    ('price:0-2500', 'Under \$25', 0, 2500),
    ('price:2500-5000', '\$25 – \$50', 2500, 5000),
    ('price:5000-10000', '\$50 – \$100', 5000, 10000),
    ('price:10000-max', '\$100+', 10000, null),
  ];

  static const List<(String id, String label, double rating)> ratingBuckets = [
    ('rating:4', '4★ & up', 4),
    ('rating:3', '3★ & up', 3),
  ];

  static Set<String> toChipIds(SearchFilter filter) {
    final ids = <String>{};
    final categoryId = filter.categoryId;
    if (categoryId != null && categoryId.isNotEmpty) {
      ids.add('cat:$categoryId');
    }
    if (filter.inStockOnly) {
      ids.add(stockInId);
    }
    final minRating = filter.minRating;
    if (minRating != null) {
      final match = ratingBuckets.where((b) => b.$3 == minRating).firstOrNull;
      if (match != null) {
        ids.add(match.$1);
      } else {
        ids.add('rating:${minRating.toStringAsFixed(0)}');
      }
    }
    for (final bucket in priceBuckets) {
      if (filter.minPriceMinor == bucket.$3 &&
          filter.maxPriceMinor == bucket.$4) {
        ids.add(bucket.$1);
        break;
      }
    }
    return ids;
  }

  static SearchFilter fromChipIds(Set<String> ids) {
    String? categoryId;
    var inStockOnly = false;
    double? minRating;
    int? minPrice;
    int? maxPrice;

    for (final id in ids) {
      if (id.startsWith('cat:')) {
        categoryId = id.substring(4);
      } else if (id == stockInId) {
        inStockOnly = true;
      } else if (id.startsWith('rating:')) {
        minRating = double.tryParse(id.substring(7)) ?? minRating;
      } else if (id.startsWith('price:')) {
        for (final bucket in priceBuckets) {
          if (bucket.$1 == id) {
            minPrice = bucket.$3;
            maxPrice = bucket.$4;
            break;
          }
        }
      }
    }

    return SearchFilter(
      categoryId: categoryId,
      inStockOnly: inStockOnly,
      minRating: minRating,
      minPriceMinor: minPrice,
      maxPriceMinor: maxPrice,
    );
  }

  static SearchFilter removeChip(SearchFilter filter, String chipId) {
    final ids = toChipIds(filter)..remove(chipId);
    return fromChipIds(ids);
  }

  static List<AppActiveFilter> toActiveFilters(
    SearchFilter filter, {
    required Map<String, String> categoryFacets,
  }) {
    final chips = <AppActiveFilter>[];
    final categoryId = filter.categoryId;
    if (categoryId != null && categoryId.isNotEmpty) {
      chips.add(
        AppActiveFilter(
          id: 'cat:$categoryId',
          label: categoryFacets[categoryId] ?? categoryId,
        ),
      );
    }
    for (final bucket in priceBuckets) {
      if (filter.minPriceMinor == bucket.$3 &&
          filter.maxPriceMinor == bucket.$4) {
        chips.add(AppActiveFilter(id: bucket.$1, label: bucket.$2));
        break;
      }
    }
    final minRating = filter.minRating;
    if (minRating != null) {
      final match = ratingBuckets.where((b) => b.$3 == minRating).firstOrNull;
      chips.add(
        AppActiveFilter(
          id: match?.$1 ?? 'rating:${minRating.toStringAsFixed(0)}',
          label: match?.$2 ?? '${minRating.toStringAsFixed(0)}★ & up',
        ),
      );
    }
    if (filter.inStockOnly) {
      chips.add(const AppActiveFilter(id: stockInId, label: 'In stock'));
    }
    return chips;
  }

  static List<AppFilterGroup> buildGroups({
    required Map<String, String> categoryFacets,
  }) {
    final categoryOptions =
        categoryFacets.entries
            .map((e) => AppFilterOption(id: 'cat:${e.key}', label: e.value))
            .toList()
          ..sort((a, b) => a.label.compareTo(b.label));

    return [
      if (categoryOptions.isNotEmpty)
        AppFilterGroup(title: 'Category', options: categoryOptions),
      AppFilterGroup(
        title: 'Price',
        options: [
          for (final bucket in priceBuckets)
            AppFilterOption(id: bucket.$1, label: bucket.$2),
        ],
      ),
      AppFilterGroup(
        title: 'Rating',
        options: [
          for (final bucket in ratingBuckets)
            AppFilterOption(id: bucket.$1, label: bucket.$2),
        ],
      ),
      const AppFilterGroup(
        title: 'Availability',
        options: [AppFilterOption(id: stockInId, label: 'In stock only')],
      ),
    ];
  }
}

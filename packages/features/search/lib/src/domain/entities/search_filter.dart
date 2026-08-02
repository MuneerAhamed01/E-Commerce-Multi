import 'package:equatable/equatable.dart';

/// Composable search facets. All non-null / enabled fields are ANDed together
/// (docs/04_FEATURE_IMPLEMENTATION_ORDER.md §5 acceptance criteria).
///
/// Within a single facet (e.g. one price range, one category), values are
/// singular on this model. Presentation maps chip selections into these fields
/// before calling [SearchProducts].
final class SearchFilter extends Equatable {
  const SearchFilter({
    this.minPriceMinor,
    this.maxPriceMinor,
    this.categoryId,
    this.minRating,
    this.inStockOnly = false,
  });

  /// Inclusive lower bound on cheapest-variant price (minor units), or null.
  final int? minPriceMinor;

  /// Inclusive upper bound on cheapest-variant price (minor units), or null.
  final int? maxPriceMinor;

  /// Exact product [categoryId] match when set.
  final String? categoryId;

  /// Inclusive minimum aggregate product rating when set.
  final double? minRating;

  /// When true, product must have at least one in-stock variant.
  final bool inStockOnly;

  static const SearchFilter empty = SearchFilter();

  bool get isEmpty =>
      minPriceMinor == null &&
      maxPriceMinor == null &&
      (categoryId == null || categoryId!.isEmpty) &&
      minRating == null &&
      !inStockOnly;

  bool get hasActiveFilters => !isEmpty;

  SearchFilter copyWith({
    int? minPriceMinor,
    int? maxPriceMinor,
    String? categoryId,
    double? minRating,
    bool? inStockOnly,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearCategoryId = false,
    bool clearMinRating = false,
  }) {
    return SearchFilter(
      minPriceMinor: clearMinPrice
          ? null
          : (minPriceMinor ?? this.minPriceMinor),
      maxPriceMinor: clearMaxPrice
          ? null
          : (maxPriceMinor ?? this.maxPriceMinor),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      inStockOnly: inStockOnly ?? this.inStockOnly,
    );
  }

  @override
  List<Object?> get props => [
    minPriceMinor,
    maxPriceMinor,
    categoryId,
    minRating,
    inStockOnly,
  ];
}

/// Result ordering for [SearchProducts] (docs/04_FEATURE_IMPLEMENTATION_ORDER.md §5).
enum SortOption { relevance, priceAsc, priceDesc, newest, rating }

extension SortOptionLabel on SortOption {
  String get label => switch (this) {
    SortOption.relevance => 'Relevance',
    SortOption.priceAsc => 'Price: Low to High',
    SortOption.priceDesc => 'Price: High to Low',
    SortOption.newest => 'Newest',
    SortOption.rating => 'Rating',
  };
}

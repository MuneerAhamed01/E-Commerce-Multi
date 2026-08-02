import '../../domain/entities/wishlist_item.dart';

/// Demo wishlist seed for Noah Patel (`user_cust_02`).
abstract final class WishlistDemoSeed {
  static const String demoCustomerId = 'user_cust_02';

  /// A handful of catalog products from [SeedData] for QA convenience.
  static final List<WishlistItem> demoItems = List<WishlistItem>.unmodifiable([
    WishlistItem(productId: 'prod_001', addedAt: DateTime.utc(2026, 1, 10, 12)),
    WishlistItem(productId: 'prod_007', addedAt: DateTime.utc(2026, 1, 11, 9)),
    WishlistItem(productId: 'prod_014', addedAt: DateTime.utc(2026, 1, 12, 18)),
  ]);
}

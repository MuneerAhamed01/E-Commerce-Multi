import 'package:core/core.dart';

import '../entities/wishlist_item.dart';

/// Persisted wishlist membership for authenticated users.
abstract interface class WishlistRepository {
  Future<Result<Failure, List<WishlistItem>>> getWishlist(String userId);

  Future<Result<Failure, WishlistItem>> addToWishlist({
    required String userId,
    required String productId,
    String? variantId,
  });

  Future<Result<Failure, void>> removeFromWishlist({
    required String userId,
    required String productId,
  });

  Future<Result<Failure, bool>> isInWishlist({
    required String userId,
    required String productId,
  });
}

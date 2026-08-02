import '../../domain/entities/wishlist_item.dart';

/// Remote-shaped wishlist API surface (mock latency / failure injection).
abstract interface class WishlistRemoteDataSource {
  Future<List<WishlistItem>> fetchWishlist(String userId);

  Future<WishlistItem> addItem({
    required String userId,
    required String productId,
    String? variantId,
  });

  Future<void> removeItem({required String userId, required String productId});

  Future<bool> contains({required String userId, required String productId});
}

import '../../domain/entities/cart.dart';

/// Remote-shaped cart data source (mock network + persistence).
abstract interface class CartRemoteDataSource {
  Future<Cart> fetchCart(String ownerId);

  Future<Cart> addItem({
    required String ownerId,
    required String productId,
    required String variantId,
    required int quantity,
  });

  Future<Cart> updateQuantity({
    required String ownerId,
    required String productId,
    required String variantId,
    required int quantity,
  });

  Future<Cart> removeItem({
    required String ownerId,
    required String productId,
    required String variantId,
  });

  Future<Cart> clearCart(String ownerId);

  Future<Cart> applyPromoCode({required String ownerId, required String code});

  Future<Cart> removePromoCode(String ownerId);

  Future<Cart> mergeGuestCart({
    required String guestOwnerId,
    required String userOwnerId,
  });
}

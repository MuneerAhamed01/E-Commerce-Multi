import 'package:core/core.dart';

import '../entities/cart.dart';

/// Persisted cart contract (mock → remote later).
abstract interface class CartRepository {
  Future<Result<Failure, Cart>> getCart(String ownerId);

  Future<Result<Failure, Cart>> addItem({
    required String ownerId,
    required String productId,
    required String variantId,
    required int quantity,
  });

  Future<Result<Failure, Cart>> updateQuantity({
    required String ownerId,
    required String productId,
    required String variantId,
    required int quantity,
  });

  Future<Result<Failure, Cart>> removeItem({
    required String ownerId,
    required String productId,
    required String variantId,
  });

  Future<Result<Failure, Cart>> clearCart(String ownerId);

  Future<Result<Failure, Cart>> applyPromoCode({
    required String ownerId,
    required String code,
  });

  Future<Result<Failure, Cart>> removePromoCode(String ownerId);

  /// Merges [guestOwnerId] into [userOwnerId] (guest → empty after merge).
  Future<Result<Failure, Cart>> mergeGuestCart({
    required String guestOwnerId,
    required String userOwnerId,
  });
}

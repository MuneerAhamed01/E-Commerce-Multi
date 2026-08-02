import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/wishlist_item.dart';
import '../repositories/wishlist_repository.dart';

final class AddToWishlist extends UseCase<WishlistItem, AddToWishlistParams> {
  const AddToWishlist(this._repository);

  final WishlistRepository _repository;

  @override
  Future<Result<Failure, WishlistItem>> call(AddToWishlistParams params) {
    return _repository.addToWishlist(
      userId: params.userId,
      productId: params.productId,
      variantId: params.variantId,
    );
  }
}

final class AddToWishlistParams extends Equatable {
  const AddToWishlistParams({
    required this.userId,
    required this.productId,
    this.variantId,
  });

  final String userId;
  final String productId;
  final String? variantId;

  @override
  List<Object?> get props => [userId, productId, variantId];
}

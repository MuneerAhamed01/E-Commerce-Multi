import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../repositories/wishlist_repository.dart';

final class RemoveFromWishlist extends UseCase<void, RemoveFromWishlistParams> {
  const RemoveFromWishlist(this._repository);

  final WishlistRepository _repository;

  @override
  Future<Result<Failure, void>> call(RemoveFromWishlistParams params) {
    return _repository.removeFromWishlist(
      userId: params.userId,
      productId: params.productId,
    );
  }
}

final class RemoveFromWishlistParams extends Equatable {
  const RemoveFromWishlistParams({
    required this.userId,
    required this.productId,
  });

  final String userId;
  final String productId;

  @override
  List<Object?> get props => [userId, productId];
}

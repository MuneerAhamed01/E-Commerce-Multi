import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../repositories/wishlist_repository.dart';

final class IsInWishlist extends UseCase<bool, IsInWishlistParams> {
  const IsInWishlist(this._repository);

  final WishlistRepository _repository;

  @override
  Future<Result<Failure, bool>> call(IsInWishlistParams params) {
    return _repository.isInWishlist(
      userId: params.userId,
      productId: params.productId,
    );
  }
}

final class IsInWishlistParams extends Equatable {
  const IsInWishlistParams({required this.userId, required this.productId});

  final String userId;
  final String productId;

  @override
  List<Object?> get props => [userId, productId];
}

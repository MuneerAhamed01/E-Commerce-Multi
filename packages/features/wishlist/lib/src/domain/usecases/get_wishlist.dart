import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/wishlist_item.dart';
import '../repositories/wishlist_repository.dart';

final class GetWishlist extends UseCase<List<WishlistItem>, GetWishlistParams> {
  const GetWishlist(this._repository);

  final WishlistRepository _repository;

  @override
  Future<Result<Failure, List<WishlistItem>>> call(GetWishlistParams params) {
    return _repository.getWishlist(params.userId);
  }
}

final class GetWishlistParams extends Equatable {
  const GetWishlistParams(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

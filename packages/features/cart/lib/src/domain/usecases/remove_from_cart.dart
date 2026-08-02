import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

final class RemoveFromCart extends UseCase<Cart, RemoveFromCartParams> {
  const RemoveFromCart(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<Failure, Cart>> call(RemoveFromCartParams params) {
    return _repository.removeItem(
      ownerId: params.ownerId,
      productId: params.productId,
      variantId: params.variantId,
    );
  }
}

final class RemoveFromCartParams extends Equatable {
  const RemoveFromCartParams({
    required this.ownerId,
    required this.productId,
    required this.variantId,
  });

  final String ownerId;
  final String productId;
  final String variantId;

  @override
  List<Object?> get props => [ownerId, productId, variantId];
}

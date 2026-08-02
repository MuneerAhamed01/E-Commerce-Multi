import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

final class UpdateCartItemQuantity
    extends UseCase<Cart, UpdateCartItemQuantityParams> {
  const UpdateCartItemQuantity(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<Failure, Cart>> call(UpdateCartItemQuantityParams params) {
    return _repository.updateQuantity(
      ownerId: params.ownerId,
      productId: params.productId,
      variantId: params.variantId,
      quantity: params.quantity,
    );
  }
}

final class UpdateCartItemQuantityParams extends Equatable {
  const UpdateCartItemQuantityParams({
    required this.ownerId,
    required this.productId,
    required this.variantId,
    required this.quantity,
  });

  final String ownerId;
  final String productId;
  final String variantId;
  final int quantity;

  @override
  List<Object?> get props => [ownerId, productId, variantId, quantity];
}

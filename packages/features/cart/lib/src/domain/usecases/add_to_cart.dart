import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

final class AddToCart extends UseCase<Cart, AddToCartParams> {
  const AddToCart(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<Failure, Cart>> call(AddToCartParams params) {
    return _repository.addItem(
      ownerId: params.ownerId,
      productId: params.productId,
      variantId: params.variantId,
      quantity: params.quantity,
    );
  }
}

final class AddToCartParams extends Equatable {
  const AddToCartParams({
    required this.ownerId,
    required this.productId,
    required this.variantId,
    this.quantity = 1,
  });

  final String ownerId;
  final String productId;
  final String variantId;
  final int quantity;

  @override
  List<Object?> get props => [ownerId, productId, variantId, quantity];
}

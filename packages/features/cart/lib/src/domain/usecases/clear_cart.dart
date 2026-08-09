import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

final class ClearCart extends UseCase<Cart, ClearCartParams> {
  const ClearCart(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<Failure, Cart>> call(ClearCartParams params) {
    return _repository.clearCart(params.ownerId);
  }
}

final class ClearCartParams extends Equatable {
  const ClearCartParams(this.ownerId);

  final String ownerId;

  @override
  List<Object?> get props => [ownerId];
}

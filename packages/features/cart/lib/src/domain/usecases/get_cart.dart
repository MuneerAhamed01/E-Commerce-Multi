import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

final class GetCart extends UseCase<Cart, GetCartParams> {
  const GetCart(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<Failure, Cart>> call(GetCartParams params) {
    return _repository.getCart(params.ownerId);
  }
}

final class GetCartParams extends Equatable {
  const GetCartParams(this.ownerId);

  final String ownerId;

  @override
  List<Object?> get props => [ownerId];
}

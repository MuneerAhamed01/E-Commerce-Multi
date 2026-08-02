import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

final class RemovePromoCode extends UseCase<Cart, RemovePromoCodeParams> {
  const RemovePromoCode(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<Failure, Cart>> call(RemovePromoCodeParams params) {
    return _repository.removePromoCode(params.ownerId);
  }
}

final class RemovePromoCodeParams extends Equatable {
  const RemovePromoCodeParams(this.ownerId);

  final String ownerId;

  @override
  List<Object?> get props => [ownerId];
}

import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

final class ApplyPromoCode extends UseCase<Cart, ApplyPromoCodeParams> {
  const ApplyPromoCode(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<Failure, Cart>> call(ApplyPromoCodeParams params) {
    return _repository.applyPromoCode(
      ownerId: params.ownerId,
      code: params.code,
    );
  }
}

final class ApplyPromoCodeParams extends Equatable {
  const ApplyPromoCodeParams({required this.ownerId, required this.code});

  final String ownerId;
  final String code;

  @override
  List<Object?> get props => [ownerId, code];
}

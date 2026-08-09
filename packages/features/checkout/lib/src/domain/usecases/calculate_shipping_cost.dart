import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../repositories/checkout_repository.dart';

final class CalculateShippingCost
    extends UseCase<Money, CalculateShippingCostParams> {
  const CalculateShippingCost(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<Result<Failure, Money>> call(CalculateShippingCostParams params) {
    return _repository.calculateShippingCost(
      methodId: params.methodId,
      postalCode: params.postalCode,
    );
  }
}

final class CalculateShippingCostParams extends Equatable {
  const CalculateShippingCostParams({
    required this.methodId,
    required this.postalCode,
  });

  final String methodId;
  final String postalCode;

  @override
  List<Object?> get props => [methodId, postalCode];
}

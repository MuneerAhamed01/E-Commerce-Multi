import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/checkout_payment_method.dart';
import '../repositories/checkout_repository.dart';

final class GetCheckoutPaymentMethods
    extends
        UseCase<List<CheckoutPaymentMethod>, GetCheckoutPaymentMethodsParams> {
  const GetCheckoutPaymentMethods(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<Result<Failure, List<CheckoutPaymentMethod>>> call(
    GetCheckoutPaymentMethodsParams params,
  ) {
    return _repository.getPaymentMethods(params.userId);
  }
}

final class GetCheckoutPaymentMethodsParams extends Equatable {
  const GetCheckoutPaymentMethodsParams(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

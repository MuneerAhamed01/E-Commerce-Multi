import 'package:core/core.dart';

import '../entities/shipping_method.dart';
import '../repositories/checkout_repository.dart';

final class GetShippingMethods extends UseCase<List<ShippingMethod>, NoParams> {
  const GetShippingMethods(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<Result<Failure, List<ShippingMethod>>> call(NoParams params) {
    return _repository.getShippingMethods();
  }
}

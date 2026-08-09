import 'package:core/core.dart';

import '../entities/order.dart';
import '../repositories/order_repository.dart';

final class CreateOrder extends UseCase<Order, CreateOrderRequest> {
  const CreateOrder(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<Failure, Order>> call(CreateOrderRequest params) {
    return _repository.createOrder(params);
  }
}

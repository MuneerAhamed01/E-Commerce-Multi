import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/order.dart';
import '../repositories/order_repository.dart';

final class GetOrder extends UseCase<Order, GetOrderParams> {
  const GetOrder(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<Failure, Order>> call(GetOrderParams params) {
    return _repository.getOrder(params.orderId);
  }
}

final class GetOrderParams extends Equatable {
  const GetOrderParams(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

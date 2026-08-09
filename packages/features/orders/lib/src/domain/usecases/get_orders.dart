import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/order.dart';
import '../repositories/order_repository.dart';

final class GetOrders extends UseCase<List<Order>, GetOrdersParams> {
  const GetOrders(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<Failure, List<Order>>> call(GetOrdersParams params) {
    return _repository.getOrders(params.customerId);
  }
}

final class GetOrdersParams extends Equatable {
  const GetOrdersParams(this.customerId);

  final String customerId;

  @override
  List<Object?> get props => [customerId];
}

import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/order.dart';
import '../repositories/order_repository.dart';

final class CancelOrder extends UseCase<Order, CancelOrderParams> {
  const CancelOrder(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<Failure, Order>> call(CancelOrderParams params) {
    return _repository.cancelOrder(
      orderId: params.orderId,
      customerId: params.customerId,
      reason: params.reason,
    );
  }
}

final class CancelOrderParams extends Equatable {
  const CancelOrderParams({
    required this.orderId,
    required this.customerId,
    required this.reason,
  });

  final String orderId;
  final String customerId;
  final String reason;

  @override
  List<Object?> get props => [orderId, customerId, reason];
}

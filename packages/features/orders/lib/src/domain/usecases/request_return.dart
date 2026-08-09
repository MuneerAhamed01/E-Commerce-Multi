import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/order.dart';
import '../repositories/order_repository.dart';

final class RequestReturn extends UseCase<Order, RequestReturnParams> {
  const RequestReturn(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<Failure, Order>> call(RequestReturnParams params) {
    return _repository.requestReturn(
      orderId: params.orderId,
      customerId: params.customerId,
      reason: params.reason,
    );
  }
}

final class RequestReturnParams extends Equatable {
  const RequestReturnParams({
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

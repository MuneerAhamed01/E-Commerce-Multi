import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/order_tracking_event.dart';
import '../repositories/order_repository.dart';

final class GetOrderTrackingEvents
    extends UseCase<List<OrderTrackingEvent>, GetOrderTrackingEventsParams> {
  const GetOrderTrackingEvents(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<Failure, List<OrderTrackingEvent>>> call(
    GetOrderTrackingEventsParams params,
  ) {
    return _repository.getTrackingEvents(params.orderId);
  }
}

final class GetOrderTrackingEventsParams extends Equatable {
  const GetOrderTrackingEventsParams(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

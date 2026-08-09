part of 'order_detail_bloc.dart';

sealed class OrderDetailEvent extends Equatable {
  const OrderDetailEvent();

  @override
  List<Object?> get props => [];
}

final class OrderDetailStarted extends OrderDetailEvent {
  const OrderDetailStarted(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

final class OrderDetailRetried extends OrderDetailEvent {
  const OrderDetailRetried();
}

final class OrderDetailCancelRequested extends OrderDetailEvent {
  const OrderDetailCancelRequested(this.reason);

  final String reason;

  @override
  List<Object?> get props => [reason];
}

final class OrderDetailReturnRequested extends OrderDetailEvent {
  const OrderDetailReturnRequested(this.reason);

  final String reason;

  @override
  List<Object?> get props => [reason];
}

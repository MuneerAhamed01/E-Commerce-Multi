part of 'order_list_bloc.dart';

sealed class OrderListEvent extends Equatable {
  const OrderListEvent();

  @override
  List<Object?> get props => [];
}

final class OrderListStarted extends OrderListEvent {
  const OrderListStarted();
}

final class OrderListRetried extends OrderListEvent {
  const OrderListRetried();
}

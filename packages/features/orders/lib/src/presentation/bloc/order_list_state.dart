part of 'order_list_bloc.dart';

sealed class OrderListState extends Equatable {
  const OrderListState();

  @override
  List<Object?> get props => [];
}

final class OrderListInitial extends OrderListState {
  const OrderListInitial();
}

final class OrderListLoading extends OrderListState {
  const OrderListLoading();
}

final class OrderListEmpty extends OrderListState {
  const OrderListEmpty();
}

final class OrderListLoaded extends OrderListState {
  const OrderListLoaded(this.orders);

  final List<Order> orders;

  @override
  List<Object?> get props => [orders];
}

final class OrderListError extends OrderListState {
  const OrderListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

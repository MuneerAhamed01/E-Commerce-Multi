part of 'order_detail_bloc.dart';

sealed class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object?> get props => [];
}

final class OrderDetailInitial extends OrderDetailState {
  const OrderDetailInitial();
}

final class OrderDetailLoading extends OrderDetailState {
  const OrderDetailLoading();
}

final class OrderDetailLoaded extends OrderDetailState {
  const OrderDetailLoaded({
    required this.order,
    required this.events,
    this.isActionInFlight = false,
    this.actionError,
  });

  final Order order;
  final List<OrderTrackingEvent> events;
  final bool isActionInFlight;
  final String? actionError;

  OrderDetailLoaded copyWith({
    Order? order,
    List<OrderTrackingEvent>? events,
    bool? isActionInFlight,
    String? actionError,
    bool clearActionError = false,
  }) {
    return OrderDetailLoaded(
      order: order ?? this.order,
      events: events ?? this.events,
      isActionInFlight: isActionInFlight ?? this.isActionInFlight,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [order, events, isActionInFlight, actionError];
}

final class OrderDetailError extends OrderDetailState {
  const OrderDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

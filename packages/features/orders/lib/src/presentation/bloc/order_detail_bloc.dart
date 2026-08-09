import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order.dart';
import '../../domain/entities/order_tracking_event.dart';
import '../../domain/usecases/cancel_order.dart';
import '../../domain/usecases/get_order.dart';
import '../../domain/usecases/get_order_tracking_events.dart';
import '../../domain/usecases/request_return.dart';

part 'order_detail_event.dart';
part 'order_detail_state.dart';

/// Loads a single order + tracking timeline; handles cancel/return actions.
final class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  OrderDetailBloc({
    required this.getOrder,
    required this.getTrackingEvents,
    required this.cancelOrder,
    required this.requestReturn,
    required this.authBloc,
  }) : super(const OrderDetailInitial()) {
    on<OrderDetailStarted>(_onStarted);
    on<OrderDetailRetried>(_onRetried);
    on<OrderDetailCancelRequested>(_onCancelRequested);
    on<OrderDetailReturnRequested>(_onReturnRequested);
  }

  final GetOrder getOrder;
  final GetOrderTrackingEvents getTrackingEvents;
  final CancelOrder cancelOrder;
  final RequestReturn requestReturn;
  final AuthBloc authBloc;

  String? _orderId;

  Future<void> _onStarted(
    OrderDetailStarted event,
    Emitter<OrderDetailState> emit,
  ) async {
    _orderId = event.orderId;
    await _load(emit);
  }

  Future<void> _onRetried(
    OrderDetailRetried event,
    Emitter<OrderDetailState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<OrderDetailState> emit) async {
    final orderId = _orderId;
    if (orderId == null || orderId.isEmpty) {
      emit(const OrderDetailError('Order not found.'));
      return;
    }

    emit(const OrderDetailLoading());
    final orderResult = await getOrder(GetOrderParams(orderId));
    if (orderResult.isFailure) {
      emit(OrderDetailError(_mapFailure(orderResult.failureOrNull!)));
      return;
    }

    final order = orderResult.valueOrNull!;
    final trackingResult = await getTrackingEvents(
      GetOrderTrackingEventsParams(orderId),
    );
    final events = trackingResult.valueOrNull ?? const <OrderTrackingEvent>[];
    emit(OrderDetailLoaded(order: order, events: events));
  }

  Future<void> _onCancelRequested(
    OrderDetailCancelRequested event,
    Emitter<OrderDetailState> emit,
  ) async {
    final current = state;
    if (current is! OrderDetailLoaded) {
      return;
    }
    if (!current.order.canCancel || current.isActionInFlight) {
      return;
    }

    final customerId = _customerId;
    if (customerId == null) {
      emit(current.copyWith(actionError: 'Sign in to cancel this order.'));
      return;
    }

    emit(current.copyWith(isActionInFlight: true, clearActionError: true));
    final result = await cancelOrder(
      CancelOrderParams(
        orderId: current.order.id,
        customerId: customerId,
        reason: event.reason,
      ),
    );
    await result.fold(
      onFailure: (failure) async {
        emit(
          current.copyWith(
            isActionInFlight: false,
            actionError: _mapFailure(failure),
          ),
        );
      },
      onSuccess: (_) async {
        await _load(emit);
      },
    );
  }

  Future<void> _onReturnRequested(
    OrderDetailReturnRequested event,
    Emitter<OrderDetailState> emit,
  ) async {
    final current = state;
    if (current is! OrderDetailLoaded) {
      return;
    }
    if (!current.order.canRequestReturn || current.isActionInFlight) {
      return;
    }

    final customerId = _customerId;
    if (customerId == null) {
      emit(current.copyWith(actionError: 'Sign in to request a return.'));
      return;
    }

    emit(current.copyWith(isActionInFlight: true, clearActionError: true));
    final result = await requestReturn(
      RequestReturnParams(
        orderId: current.order.id,
        customerId: customerId,
        reason: event.reason,
      ),
    );
    await result.fold(
      onFailure: (failure) async {
        emit(
          current.copyWith(
            isActionInFlight: false,
            actionError: _mapFailure(failure),
          ),
        );
      },
      onSuccess: (_) async {
        await _load(emit);
      },
    );
  }

  String? get _customerId {
    final auth = authBloc.state;
    if (auth is AuthAuthenticated) {
      return auth.session.user.id;
    }
    return null;
  }

  String _mapFailure(Failure failure) {
    return failure.message ?? 'Something went wrong. Please try again.';
  }
}

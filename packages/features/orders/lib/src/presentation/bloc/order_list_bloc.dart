import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order.dart';
import '../../domain/usecases/get_orders.dart';

part 'order_list_event.dart';
part 'order_list_state.dart';

/// Loads the authenticated customer's order history (newest first).
final class OrderListBloc extends Bloc<OrderListEvent, OrderListState> {
  OrderListBloc({required this.getOrders, required this.authBloc})
    : super(const OrderListInitial()) {
    on<OrderListStarted>(_onStarted);
    on<OrderListRetried>(_onRetried);
  }

  final GetOrders getOrders;
  final AuthBloc authBloc;

  Future<void> _onStarted(
    OrderListStarted event,
    Emitter<OrderListState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _onRetried(
    OrderListRetried event,
    Emitter<OrderListState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<OrderListState> emit) async {
    final customerId = _customerId;
    if (customerId == null) {
      emit(const OrderListError('Sign in to view your orders.'));
      return;
    }

    emit(const OrderListLoading());
    final result = await getOrders(GetOrdersParams(customerId));
    result.fold(
      onFailure: (failure) => emit(OrderListError(_mapFailure(failure))),
      onSuccess: (orders) {
        if (orders.isEmpty) {
          emit(const OrderListEmpty());
        } else {
          emit(OrderListLoaded(orders));
        }
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
    return failure.message ??
        'Unable to load orders right now. Please try again.';
  }
}

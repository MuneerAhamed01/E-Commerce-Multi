import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orders/orders.dart';

import '../helpers/orders_test_harness.dart';

void main() {
  late OrdersTestHarness harness;

  setUp(() async {
    harness = await OrdersTestHarness.create();
  });

  tearDown(() async {
    await harness.dispose();
  });

  blocTest<OrderListBloc, OrderListState>(
    'OrderListStarted emits loading then loaded',
    build: () => harness.createListBloc(),
    act: (bloc) => bloc.add(const OrderListStarted()),
    expect: () => [
      const OrderListLoading(),
      isA<OrderListLoaded>().having(
        (s) => s.orders.every((o) => o.customerId == harness.userId),
        'own orders',
        isTrue,
      ),
    ],
  );

  blocTest<OrderDetailBloc, OrderDetailState>(
    'cancel success updates status and guards double-cancel',
    build: () => harness.createDetailBloc(),
    act: (bloc) async {
      final orderId = harness.setOwnedOrderStatus(OrderStatus.placed);
      bloc.add(OrderDetailStarted(orderId));
      await bloc.stream.firstWhere((s) => s is OrderDetailLoaded);
      bloc.add(const OrderDetailCancelRequested('Changed my mind'));
      await bloc.stream.firstWhere(
        (s) =>
            s is OrderDetailLoaded && s.order.status == OrderStatus.cancelled,
      );
      // Second cancel should be ignored by canCancel guard (no new states).
      bloc.add(const OrderDetailCancelRequested('Changed my mind'));
    },
    expect: () => [
      const OrderDetailLoading(),
      isA<OrderDetailLoaded>().having(
        (s) => s.order.status,
        'initial',
        OrderStatus.placed,
      ),
      isA<OrderDetailLoaded>().having(
        (s) => s.isActionInFlight,
        'in flight',
        isTrue,
      ),
      const OrderDetailLoading(),
      isA<OrderDetailLoaded>().having(
        (s) => s.order.status,
        'cancelled',
        OrderStatus.cancelled,
      ),
    ],
  );
}

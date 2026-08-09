import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orders/orders.dart';
import 'package:orders/src/data/datasources/mock_order_remote_data_source.dart';
import 'package:orders/src/data/mappers/order_tracking_builder.dart';
import 'package:orders/src/data/mappers/seed_order_mapper.dart';
import 'package:orders/src/data/repositories/mock_order_repository_impl.dart';

void main() {
  group('OrderStatus policy', () {
    test('cancel allowed only for placed and processing', () {
      expect(OrderStatus.placed.canCancel, isTrue);
      expect(OrderStatus.processing.canCancel, isTrue);
      expect(OrderStatus.shipped.canCancel, isFalse);
      expect(OrderStatus.delivered.canCancel, isFalse);
      expect(OrderStatus.cancelled.canCancel, isFalse);
      expect(OrderStatus.returnRequested.canCancel, isFalse);
      expect(OrderStatus.returned.canCancel, isFalse);
    });

    test('return allowed only for delivered', () {
      expect(OrderStatus.delivered.canRequestReturn, isTrue);
      expect(OrderStatus.placed.canRequestReturn, isFalse);
      expect(OrderStatus.shipped.canRequestReturn, isFalse);
      expect(OrderStatus.returnRequested.canRequestReturn, isFalse);
    });
  });

  group('OrderTrackingBuilder', () {
    test('events are chronological for delivered orders', () {
      final order = Order(
        id: 'ord_t1',
        orderNumber: 'WL-T1',
        customerId: 'user_cust_02',
        status: OrderStatus.delivered,
        createdAt: DateTime.utc(2026, 8, 1, 10),
        items: const [
          OrderLineItem(
            productId: 'p1',
            productName: 'Demo',
            quantity: 1,
            unitPrice: Money(minorUnits: 1000, currencyCode: 'USD'),
          ),
        ],
        shippingAddress: const Address(
          line1: '1 St',
          city: 'Austin',
          state: 'TX',
          postalCode: '78701',
          countryCode: 'US',
        ),
        subtotal: const Money(minorUnits: 1000, currencyCode: 'USD'),
        shipping: Money.zero('USD'),
        tax: Money.zero('USD'),
        total: const Money(minorUnits: 1000, currencyCode: 'USD'),
      );

      final events = OrderTrackingBuilder.build(order);
      expect(events.length, greaterThanOrEqualTo(3));
      for (var i = 1; i < events.length; i++) {
        expect(
          events[i].occurredAt.isAfter(events[i - 1].occurredAt) ||
              events[i].occurredAt.isAtSameMomentAs(events[i - 1].occurredAt),
          isTrue,
        );
      }
      expect(events.last.status, OrderStatus.delivered);
    });
  });

  group('OrderRepository cancel/return/list', () {
    late MockDeveloperControls controls;
    late MockSeedStore store;
    late OrderRepository repository;

    setUp(() {
      controls = MockDeveloperControls()..latencyDisabled = true;
      store = MockSeedStore(controls: controls);
      const appConfig = AppConfig(
        environment: Environment.dev,
        dataSourceMode: DataSourceMode.mock,
        logLevel: LogLevel.debug,
        mockLatencyMin: Duration.zero,
        mockLatencyMax: Duration.zero,
        isDeveloperModeAvailable: true,
      );
      final simulator = MockNetworkSimulator(
        appConfig: appConfig,
        controls: controls,
        random: Random(0),
      );
      repository = MockOrderRepositoryImpl(
        remote: MockOrderRemoteDataSource(simulator: simulator, store: store),
      );
    });

    test('getOrders sorts newest first', () async {
      final result = await repository.getOrders('user_cust_02');
      expect(result.isSuccess, isTrue);
      final orders = result.valueOrNull!;
      expect(orders, isNotEmpty);
      for (var i = 1; i < orders.length; i++) {
        expect(
          orders[i - 1].createdAt.isAfter(orders[i].createdAt) ||
              orders[i - 1].createdAt.isAtSameMomentAs(orders[i].createdAt),
          isTrue,
        );
      }
    });

    test(
      'cancel succeeds for placed order and fails on second cancel',
      () async {
        final placed = store.orders.firstWhere((o) => o.status == 'pending');
        final customerId = placed.customerId;

        final cancelled = await repository.cancelOrder(
          orderId: placed.id,
          customerId: customerId,
          reason: 'Changed my mind',
        );
        expect(cancelled.isSuccess, isTrue);
        expect(cancelled.valueOrNull!.status, OrderStatus.cancelled);

        final again = await repository.cancelOrder(
          orderId: placed.id,
          customerId: customerId,
          reason: 'Changed my mind',
        );
        expect(again.isFailure, isTrue);
        expect(again.failureOrNull, isA<ValidationFailure>());
      },
    );

    test('cancel rejected for shipped order', () async {
      final shipped = store.orders.firstWhere((o) => o.status == 'shipped');
      final result = await repository.cancelOrder(
        orderId: shipped.id,
        customerId: shipped.customerId,
        reason: 'Changed my mind',
      );
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
    });

    test(
      'requestReturn succeeds for delivered and rejects otherwise',
      () async {
        final delivered = store.orders.firstWhere(
          (o) => o.status == 'delivered',
        );
        final ok = await repository.requestReturn(
          orderId: delivered.id,
          customerId: delivered.customerId,
          reason: 'Item damaged',
        );
        expect(ok.isSuccess, isTrue);
        expect(ok.valueOrNull!.status, OrderStatus.returnRequested);

        final processing = store.orders.firstWhere((o) => o.status == 'paid');
        final bad = await repository.requestReturn(
          orderId: processing.id,
          customerId: processing.customerId,
          reason: 'Item damaged',
        );
        expect(bad.isFailure, isTrue);
        expect(bad.failureOrNull, isA<ValidationFailure>());
      },
    );

    test(
      'tracking includes return stages when status is returnRequested',
      () async {
        final delivered = store.orders.firstWhere(
          (o) => o.status == 'delivered',
        );
        await repository.requestReturn(
          orderId: delivered.id,
          customerId: delivered.customerId,
          reason: 'Wrong item',
        );
        final tracking = await repository.getTrackingEvents(delivered.id);
        expect(tracking.isSuccess, isTrue);
        final events = tracking.valueOrNull!;
        expect(
          events.map((e) => e.status),
          contains(OrderStatus.returnRequested),
        );
        for (var i = 1; i < events.length; i++) {
          expect(
            !events[i].occurredAt.isBefore(events[i - 1].occurredAt),
            isTrue,
          );
        }
      },
    );

    test('seed includes returnRequested/returned statuses', () {
      expect(store.orders.any((o) => o.status == 'returnRequested'), isTrue);
      expect(store.orders.any((o) => o.status == 'returned'), isTrue);
      final rr = store.orders.firstWhere((o) => o.status == 'returnRequested');
      expect(SeedOrderMapper.toDomain(rr).status, OrderStatus.returnRequested);
    });
  });
}

import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orders/orders.dart';
import 'package:orders/src/data/datasources/mock_order_remote_data_source.dart';
import 'package:orders/src/data/mappers/seed_order_mapper.dart';
import 'package:orders/src/data/repositories/mock_order_repository_impl.dart';

void main() {
  group('OrderStatus.fromSeed', () {
    test('maps seed strings to domain statuses', () {
      expect(OrderStatus.fromSeed('pending'), OrderStatus.placed);
      expect(OrderStatus.fromSeed('paid'), OrderStatus.processing);
      expect(OrderStatus.fromSeed('shipped'), OrderStatus.shipped);
      expect(OrderStatus.fromSeed('delivered'), OrderStatus.delivered);
      expect(OrderStatus.fromSeed('cancelled'), OrderStatus.cancelled);
      expect(
        OrderStatus.fromSeed('returnRequested'),
        OrderStatus.returnRequested,
      );
      expect(OrderStatus.fromSeed('returned'), OrderStatus.returned);
    });

    test('round-trips placed/processing via toSeed', () {
      expect(OrderStatus.placed.toSeed(), 'pending');
      expect(OrderStatus.processing.toSeed(), 'paid');
      expect(
        OrderStatus.fromSeed(OrderStatus.placed.toSeed()),
        OrderStatus.placed,
      );
    });
  });

  group('OrderRepository', () {
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

    test('createOrder appends and getOrder returns mapped Order', () async {
      final before = store.orders.length;
      final create = await repository.createOrder(
        CreateOrderRequest(
          customerId: 'user_cust_02',
          items: const [
            OrderLineItem(
              productId: 'prod_001',
              productName: 'Demo',
              quantity: 2,
              unitPrice: Money(minorUnits: 1999, currencyCode: 'USD'),
              variantId: 'v1',
              variantLabel: 'Default',
            ),
          ],
          shippingAddress: const Address(
            line1: '1 Test St',
            city: 'Austin',
            state: 'TX',
            postalCode: '78701',
            countryCode: 'US',
            label: 'Home',
          ),
          subtotal: const Money(minorUnits: 3998, currencyCode: 'USD'),
          shipping: const Money(minorUnits: 599, currencyCode: 'USD'),
          tax: Money.zero('USD'),
          total: const Money(minorUnits: 4597, currencyCode: 'USD'),
          paymentMethodLabel: 'Visa ••••4242',
          shippingMethodLabel: 'Standard',
        ),
      );

      expect(create.isSuccess, isTrue);
      final order = create.valueOrNull!;
      expect(store.orders.length, before + 1);
      expect(order.status, OrderStatus.placed);
      expect(store.orders.first.status, 'pending');
      expect(order.paymentMethodLabel, 'Visa ••••4242');
      expect(order.shippingMethodLabel, 'Standard');

      final fetched = await repository.getOrder(order.id);
      expect(fetched.isSuccess, isTrue);
      expect(fetched.valueOrNull!.orderNumber, order.orderNumber);
      expect(fetched.valueOrNull!.paymentMethodLabel, 'Visa ••••4242');
    });

    test('getOrders filters by customer', () async {
      final result = await repository.getOrders('user_cust_02');
      expect(result.isSuccess, isTrue);
      final orders = result.valueOrNull!;
      expect(orders.every((o) => o.customerId == 'user_cust_02'), isTrue);
    });

    test('seed mapper maps pending→placed and paid→processing', () {
      final seed = store.orders.firstWhere((o) => o.status == 'pending');
      expect(SeedOrderMapper.toDomain(seed).status, OrderStatus.placed);
      final paid = store.orders.firstWhere((o) => o.status == 'paid');
      expect(SeedOrderMapper.toDomain(paid).status, OrderStatus.processing);
    });
  });
}

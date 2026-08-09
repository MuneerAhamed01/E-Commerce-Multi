import 'package:bloc_test/bloc_test.dart';
import 'package:checkout/checkout.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/checkout_test_harness.dart';

void main() {
  late CheckoutTestHarness harness;

  setUp(() async {
    harness = await CheckoutTestHarness.create();
  });

  tearDown(() async {
    await harness.dispose();
  });

  blocTest<CheckoutBloc, CheckoutState>(
    'loads ready state with seeded addresses for demo user',
    build: () {
      return harness.createCheckoutBloc();
    },
    setUp: () async {
      await harness.seedCartLine();
    },
    act: (bloc) => bloc.add(const CheckoutStarted()),
    wait: const Duration(milliseconds: 50),
    expect: () => [
      isA<CheckoutLoading>(),
      isA<CheckoutReady>().having((s) => s.addresses, 'addresses', isNotEmpty),
    ],
  );

  blocTest<CheckoutBloc, CheckoutState>(
    'double PlaceOrderRequested does not create duplicate orders',
    build: () => harness.createCheckoutBloc(),
    setUp: () async {
      await harness.seedCartLine();
    },
    act: (bloc) async {
      bloc.add(const CheckoutStarted());
      await bloc.stream.firstWhere((s) => s is CheckoutReady);
      final before = harness.store.orders.length;
      bloc.add(const CheckoutPlaceOrderRequested());
      bloc.add(const CheckoutPlaceOrderRequested());
      await bloc.stream.firstWhere((s) => s is CheckoutPlaced);
      expect(harness.store.orders.length, before + 1);
    },
    wait: const Duration(milliseconds: 200),
    verify: (bloc) {
      expect(bloc.state, isA<CheckoutPlaced>());
    },
  );

  blocTest<CheckoutBloc, CheckoutState>(
    'shipping selection updates cost',
    build: () => harness.createCheckoutBloc(),
    setUp: () async {
      await harness.seedCartLine();
    },
    act: (bloc) async {
      bloc.add(const CheckoutStarted());
      await bloc.stream.firstWhere((s) => s is CheckoutReady);
      bloc.add(const CheckoutShippingSelected('ship_express'));
    },
    wait: const Duration(milliseconds: 100),
    verify: (bloc) {
      final state = bloc.state;
      expect(state, isA<CheckoutReady>());
      final ready = state as CheckoutReady;
      expect(ready.session.shippingMethodId, 'ship_express');
      expect(ready.shippingCost?.minorUnits, 1299);
    },
  );
}

import 'package:checkout/checkout.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orders/orders.dart';

import '../helpers/checkout_test_harness.dart';

void main() {
  late CheckoutTestHarness harness;
  CheckoutBloc? bloc;

  setUp(() async {
    harness = await CheckoutTestHarness.create();
  });

  tearDown(() async {
    await bloc?.close();
    bloc = null;
    await harness.dispose();
  });

  testWidgets('address screen shows stepper and addresses', (tester) async {
    await tester.runAsync(() async {
      await harness.seedCartLine();
      bloc = harness.createCheckoutBloc()..add(const CheckoutStarted());
      await bloc!.stream.firstWhere(
        (s) => s is CheckoutReady || s is CheckoutError,
      );
    });

    await tester.pumpWidget(
      BlocProvider<CheckoutBloc>.value(
        value: bloc!,
        child: const MaterialApp(home: CheckoutAddressScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Shipping address'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.textContaining('Home'), findsWidgets);
  });

  testWidgets('confirmation screen shows order stub copy', (tester) async {
    late String orderId;
    await tester.runAsync(() async {
      await harness.seedCartLine();
      final addresses = await harness.getSavedAddresses(
        GetSavedAddressesParams(harness.userId),
      );
      final address = addresses.valueOrNull!.first;
      final shipping = (await harness.getShippingMethods(
        const NoParams(),
      )).valueOrNull!.first;
      final payment = (await harness.getCheckoutPaymentMethods(
        GetCheckoutPaymentMethodsParams(harness.userId),
      )).valueOrNull!.first;

      final placed = await harness.placeOrder(
        PlaceOrderParams(
          customerId: harness.userId,
          session: CheckoutSession(
            selectedAddressId: address.id,
            shippingMethodId: shipping.id,
            paymentMethodId: payment.id,
          ),
          addresses: addresses.valueOrNull!,
          shippingMethod: shipping,
          paymentMethod: payment,
        ),
      );
      orderId = placed.valueOrNull!.id;
      getIt.registerFactory<GetOrder>(() => GetOrder(harness.orderRepository));
    });

    await tester.pumpWidget(
      MaterialApp(home: CheckoutConfirmationScreen(orderId: orderId)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Thank you!'), findsOneWidget);
    expect(find.textContaining('Phase 15'), findsOneWidget);
    expect(find.text('Continue shopping'), findsOneWidget);
  });
}

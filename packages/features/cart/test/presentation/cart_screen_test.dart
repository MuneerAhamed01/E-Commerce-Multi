import 'package:cart/cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/cart_test_harness.dart';

void main() {
  late CartTestHarness harness;
  CartBloc? bloc;

  setUp(() async {
    harness = await CartTestHarness.create();
  });

  tearDown(() async {
    await bloc?.close();
    bloc = null;
    await harness.dispose();
  });

  Future<void> waitLoaded(CartBloc cubit) async {
    if (cubit.state is CartLoaded) {
      return;
    }
    await cubit.stream
        .firstWhere((s) => s is CartLoaded || s is CartError)
        .timeout(const Duration(seconds: 5));
  }

  testWidgets('empty cart shows Start Shopping CTA', (tester) async {
    await tester.runAsync(() async {
      bloc = harness.createBloc();
      await waitLoaded(bloc!);
    });
    expect((bloc!.state as CartLoaded).cart.isEmpty, isTrue);

    await tester.pumpWidget(
      BlocProvider<CartBloc>.value(
        value: bloc!,
        child: const MaterialApp(home: CartScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('Start Shopping'), findsOneWidget);
  });

  testWidgets('cart with items shows line and summary', (tester) async {
    await tester.runAsync(() async {
      bloc = harness.createBloc();
      await waitLoaded(bloc!);
      bloc!.add(
        const CartItemAdded(
          productId: 'prod_001',
          variantId: 'prod_001_var_default',
        ),
      );
      await bloc!.stream.firstWhere((s) => s is CartLoaded && !s.cart.isEmpty);
    });

    await tester.pumpWidget(
      BlocProvider<CartBloc>.value(
        value: bloc!,
        child: const MaterialApp(home: CartScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Your cart is empty'), findsNothing);
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Subtotal'), findsOneWidget);
    expect(find.byType(CartLineItem), findsOneWidget);
  });
}

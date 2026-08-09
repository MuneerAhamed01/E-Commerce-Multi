import 'package:bloc_test/bloc_test.dart';
import 'package:cart/cart.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/cart_test_harness.dart';

void main() {
  late CartTestHarness harness;

  setUp(() async {
    harness = await CartTestHarness.create();
  });

  tearDown(() async {
    await harness.dispose();
  });

  Future<void> waitLoaded(CartBloc bloc) async {
    if (bloc.state is CartLoaded) {
      return;
    }
    await bloc.stream
        .firstWhere((s) => s is CartLoaded || s is CartError)
        .timeout(const Duration(seconds: 5));
  }

  test('starts with empty cart', () async {
    final bloc = harness.createBloc();
    addTearDown(bloc.close);
    await waitLoaded(bloc);
    final loaded = bloc.state as CartLoaded;
    expect(loaded.cart.isEmpty, isTrue);
    expect(loaded.itemCount, 0);
  });

  blocTest<CartBloc, CartState>(
    'add then update then remove',
    build: () => harness.createBloc(),
    wait: const Duration(milliseconds: 100),
    act: (bloc) async {
      await waitLoaded(bloc);
      bloc.add(
        const CartItemAdded(
          productId: 'prod_001',
          variantId: 'prod_001_var_default',
        ),
      );
      await bloc.stream.firstWhere((s) => s is CartLoaded && s.itemCount == 1);
      bloc.add(
        const CartQuantityChanged(
          productId: 'prod_001',
          variantId: 'prod_001_var_default',
          quantity: 2,
        ),
      );
      await bloc.stream.firstWhere((s) => s is CartLoaded && s.itemCount == 2);
      bloc.add(
        const CartItemRemoved(
          productId: 'prod_001',
          variantId: 'prod_001_var_default',
        ),
      );
      await bloc.stream.firstWhere((s) => s is CartLoaded && s.cart.isEmpty);
    },
    verify: (bloc) {
      expect(bloc.state, isA<CartLoaded>());
      expect((bloc.state as CartLoaded).cart.isEmpty, isTrue);
    },
  );

  blocTest<CartBloc, CartState>(
    'promo success and failure',
    build: () => harness.createBloc(),
    wait: const Duration(milliseconds: 100),
    act: (bloc) async {
      await waitLoaded(bloc);
      bloc.add(
        const CartItemAdded(
          productId: 'prod_001',
          variantId: 'prod_001_var_default',
          quantity: 2,
        ),
      );
      await bloc.stream.firstWhere((s) => s is CartLoaded && s.itemCount >= 2);
      bloc.add(const CartPromoApplied(CartPromoCatalog.save10));
      await bloc.stream.firstWhere(
        (s) =>
            s is CartLoaded &&
            s.cart.appliedPromoCode == CartPromoCatalog.save10,
      );
      bloc.add(const CartPromoApplied(CartPromoCatalog.invalid));
      await bloc.stream.firstWhere(
        (s) => s is CartLoaded && s.promoError != null,
      );
    },
    verify: (bloc) {
      final loaded = bloc.state as CartLoaded;
      expect(loaded.cart.appliedPromoCode, CartPromoCatalog.save10);
      expect(loaded.promoError, isNotNull);
      expect(loaded.pricing.discount.minorUnits, greaterThan(0));
    },
  );
}

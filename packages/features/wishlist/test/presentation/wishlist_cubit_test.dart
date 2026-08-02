import 'package:authentication/authentication.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wishlist/wishlist.dart';

import '../helpers/wishlist_test_harness.dart';

void main() {
  late WishlistTestHarness harness;

  setUp(() async {
    harness = await WishlistTestHarness.create();
  });

  tearDown(() async {
    await harness.dispose();
  });

  test('guest auth emits WishlistGuest', () async {
    final cubit = harness.createCubit();
    addTearDown(cubit.close);
    await _waitFor(cubit, (s) => s is WishlistGuest);
    expect(cubit.state, const WishlistGuest());
  });

  test('authenticated load seeds demo membership', () async {
    await harness.loginAsDemoCustomer();
    final cubit = harness.createCubit();
    addTearDown(cubit.close);
    await _waitFor(cubit, (s) => s is WishlistLoaded);
    final loaded = cubit.state as WishlistLoaded;
    expect(
      loaded.productIds,
      containsAll(['prod_001', 'prod_007', 'prod_014']),
    );
  });

  test('toggle adds then removes a product', () async {
    await harness.loginAsDemoCustomer();
    final cubit = harness.createCubit();
    addTearDown(cubit.close);
    await _waitFor(cubit, (s) => s is WishlistLoaded);

    await cubit.toggle(productId: 'prod_020');
    await _waitFor(cubit, (s) => s is WishlistLoaded && s.contains('prod_020'));
    expect(cubit.isInWishlist('prod_020'), isTrue);

    await cubit.toggle(productId: 'prod_020');
    await _waitFor(
      cubit,
      (s) => s is WishlistLoaded && !s.contains('prod_020'),
    );
    expect(cubit.isInWishlist('prod_020'), isFalse);
  });

  test('guest queueToggle flushes as add after login', () async {
    final cubit = harness.createCubit();
    addTearDown(cubit.close);
    await _waitFor(cubit, (s) => s is WishlistGuest);

    cubit.queueToggle(productId: 'prod_033');
    await harness.loginAs(
      email: 'mia.garcia03@example.com',
      password: AuthDemoCredentials.mockPassword,
    );
    await _waitFor(cubit, (s) => s is WishlistLoaded && s.contains('prod_033'));
    expect(cubit.isInWishlist('prod_033'), isTrue);
  });
}

Future<void> _waitFor(
  WishlistCubit cubit,
  bool Function(WishlistState state) predicate,
) async {
  if (predicate(cubit.state)) {
    return;
  }
  await cubit.stream.firstWhere(predicate).timeout(const Duration(seconds: 3));
}

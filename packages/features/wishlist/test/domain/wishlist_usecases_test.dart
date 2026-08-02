import 'package:flutter_test/flutter_test.dart';
import 'package:wishlist/src/data/mock/wishlist_demo_seed.dart';
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

  test('demo customer is pre-seeded with sample product ids', () async {
    final result = await harness.getWishlist(
      const GetWishlistParams(WishlistDemoSeed.demoCustomerId),
    );
    expect(result.isSuccess, isTrue);
    final items = result.valueOrNull!;
    expect(
      items.map((e) => e.productId),
      containsAll(['prod_001', 'prod_007', 'prod_014']),
    );
  });

  test('add / isIn / remove round-trip for a fresh user', () async {
    const userId = 'user_cust_99';

    var contains = await harness.isInWishlist(
      const IsInWishlistParams(userId: userId, productId: 'prod_002'),
    );
    expect(contains.valueOrNull, isFalse);

    final added = await harness.addToWishlist(
      const AddToWishlistParams(userId: userId, productId: 'prod_002'),
    );
    expect(added.isSuccess, isTrue);
    expect(added.valueOrNull!.productId, 'prod_002');

    contains = await harness.isInWishlist(
      const IsInWishlistParams(userId: userId, productId: 'prod_002'),
    );
    expect(contains.valueOrNull, isTrue);

    final removed = await harness.removeFromWishlist(
      const RemoveFromWishlistParams(userId: userId, productId: 'prod_002'),
    );
    expect(removed.isSuccess, isTrue);

    contains = await harness.isInWishlist(
      const IsInWishlistParams(userId: userId, productId: 'prod_002'),
    );
    expect(contains.valueOrNull, isFalse);
  });

  test('developer reset restores demo seed and clears other users', () async {
    await harness.addToWishlist(
      const AddToWishlistParams(userId: 'user_other', productId: 'prod_010'),
    );
    await harness.removeFromWishlist(
      const RemoveFromWishlistParams(
        userId: WishlistDemoSeed.demoCustomerId,
        productId: 'prod_001',
      ),
    );

    harness.controls.resetMockData();

    final demo = await harness.getWishlist(
      const GetWishlistParams(WishlistDemoSeed.demoCustomerId),
    );
    expect(
      demo.valueOrNull!.map((e) => e.productId),
      containsAll(['prod_001', 'prod_007', 'prod_014']),
    );

    final other = await harness.getWishlist(
      const GetWishlistParams('user_other'),
    );
    expect(other.valueOrNull, isEmpty);
  });
}

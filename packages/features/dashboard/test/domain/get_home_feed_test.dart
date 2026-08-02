import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/dashboard_test_harness.dart';

void main() {
  late DashboardTestHarness harness;

  setUp(() {
    harness = DashboardTestHarness.create();
  });

  test(
    'GetHomeFeed returns banners, categories, and featured products',
    () async {
      final result = await harness.getHomeFeed(const NoParams());

      expect(result.isSuccess, isTrue, reason: result.failureOrNull?.message);
      final feed = result.valueOrNull!;
      expect(feed.banners, isNotEmpty);
      expect(feed.featuredCategories, isNotEmpty);
      expect(feed.featuredProducts, isNotEmpty);
      expect(
        feed.featuredCategories.every((c) => c.id.startsWith('cat_')),
        isTrue,
      );
      expect(
        feed.featuredProducts.every((p) => p.id.startsWith('prod_')),
        isTrue,
      );
    },
  );

  test('featured products prefer isFeatured seed items', () async {
    final result = await harness.getHomeFeed(const NoParams());
    final products = result.valueOrNull!.featuredProducts;
    final featuredIds = harness.store.products
        .where((p) => p.isFeatured)
        .map((p) => p.id)
        .toSet();

    expect(products.every((p) => featuredIds.contains(p.id)), isTrue);
  });

  test('simulated failure maps to ServerFailure', () async {
    harness.controls.forceFailure('dashboard.homeFeed');
    final result = await harness.getHomeFeed(const NoParams());

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ServerFailure>());
  });
}

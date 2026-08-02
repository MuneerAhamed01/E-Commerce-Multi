import 'package:flutter_test/flutter_test.dart';

import '../helpers/dashboard_test_harness.dart';

void main() {
  late DashboardTestHarness harness;

  setUp(() {
    harness = DashboardTestHarness.create();
  });

  test('repository aggregates seed categories as top-level only', () async {
    final result = await harness.repository.getHomeFeed();
    final categories = result.valueOrNull!.featuredCategories;
    final topLevelIds = harness.store.categories
        .where((c) => c.parentId == null)
        .map((c) => c.id)
        .toSet();

    expect(categories.every((c) => topLevelIds.contains(c.id)), isTrue);
  });

  test('empty store yields empty featured sections (banners remain)', () async {
    harness.store.products.clear();
    harness.store.categories.clear();

    final result = await harness.repository.getHomeFeed();
    final feed = result.valueOrNull!;

    expect(result.isSuccess, isTrue);
    expect(feed.featuredProducts, isEmpty);
    expect(feed.featuredCategories, isEmpty);
    expect(feed.banners, isNotEmpty);
  });
}

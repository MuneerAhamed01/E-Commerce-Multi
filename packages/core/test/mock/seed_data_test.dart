import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('SeedData', () {
    test('provides dozens of products for pagination demos', () {
      expect(SeedData.products.length, greaterThanOrEqualTo(50));
      expect(SeedData.categories.length, greaterThanOrEqualTo(15));
      expect(SeedData.users.length, greaterThanOrEqualTo(10));
      expect(SeedData.orders.length, greaterThanOrEqualTo(20));
    });

    test('category tree reaches at least three levels', () {
      final byId = {for (final c in SeedData.categories) c.id: c};
      final depths = SeedData.categories.map((category) {
        var depth = 1;
        var parentId = category.parentId;
        while (parentId != null) {
          depth++;
          parentId = byId[parentId]?.parentId;
        }
        return depth;
      });
      expect(depths, contains(greaterThanOrEqualTo(3)));
    });

    test('product category ids resolve to seeded categories', () {
      final categoryIds = SeedData.categories.map((c) => c.id).toSet();
      for (final product in SeedData.products) {
        expect(categoryIds, contains(product.categoryId));
      }
    });
  });

  group('MockSeedStore', () {
    test('reset restores seed snapshot after mutation', () {
      final controls = MockDeveloperControls();
      final store = MockSeedStore(controls: controls);
      final originalCount = store.products.length;

      store.products.removeLast();
      expect(store.products.length, originalCount - 1);

      controls.resetMockData();
      expect(store.products.length, originalCount);
    });
  });
}

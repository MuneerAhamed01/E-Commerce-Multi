import 'package:categories/src/data/mock/category_tree_builder.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildTree nests ≥3 levels from seed data', () {
    final roots = CategoryTreeBuilder.buildTree(SeedData.categories);

    expect(roots, isNotEmpty);
    expect(
      CategoryTreeBuilder.flatten(roots).length,
      SeedData.categories.length,
    );
    expect(CategoryTreeBuilder.maxDepth(roots), greaterThanOrEqualTo(3));

    final electronics = roots.firstWhere((c) => c.id == 'cat_electronics');
    final phones = electronics.children.firstWhere(
      (c) => c.id == 'cat_electronics_phones',
    );
    expect(
      phones.children.any((c) => c.id == 'cat_electronics_phones_cases'),
      isTrue,
    );
  });

  test('detailFor returns ancestors root-first for deep node', () {
    final roots = CategoryTreeBuilder.buildTree(SeedData.categories);
    final detail = CategoryTreeBuilder.detailFor(
      roots,
      'cat_electronics_phones_cases',
    );

    expect(detail, isNotNull);
    expect(detail!.category.id, 'cat_electronics_phones_cases');
    expect(detail.ancestors.map((c) => c.id).toList(), [
      'cat_electronics',
      'cat_electronics_phones',
    ]);
    expect(detail.path.map((c) => c.id).toList(), [
      'cat_electronics',
      'cat_electronics_phones',
      'cat_electronics_phones_cases',
    ]);
  });

  test('detailFor returns null for unknown id', () {
    final roots = CategoryTreeBuilder.buildTree(SeedData.categories);
    expect(CategoryTreeBuilder.detailFor(roots, 'cat_missing'), isNull);
  });
}

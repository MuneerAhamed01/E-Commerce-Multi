import 'package:categories/src/data/mock/category_tree_builder.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/categories_test_harness.dart';

void main() {
  late CategoriesTestHarness harness;

  setUp(() {
    harness = CategoriesTestHarness.create();
  });

  test('GetCategoryTree returns rooted forest from seed', () async {
    final result = await harness.getCategoryTree(const NoParams());

    expect(result.isSuccess, isTrue, reason: result.failureOrNull?.message);
    final roots = result.valueOrNull!;
    expect(roots.every((c) => c.isRoot), isTrue);
    expect(
      CategoryTreeBuilder.flatten(roots).length,
      harness.store.categories.length,
    );
    expect(CategoryTreeBuilder.maxDepth(roots), greaterThanOrEqualTo(3));
  });

  test('simulated tree failure maps to ServerFailure', () async {
    harness.controls.forceFailure('categories.tree');
    final result = await harness.getCategoryTree(const NoParams());

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ServerFailure>());
  });
}

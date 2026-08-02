import 'package:categories/categories.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/categories_test_harness.dart';

void main() {
  late CategoriesTestHarness harness;

  setUp(() {
    harness = CategoriesTestHarness.create();
  });

  test('GetCategoryDetail returns category with children', () async {
    final result = await harness.getCategoryDetail(
      const GetCategoryDetailParams('cat_electronics'),
    );

    expect(result.isSuccess, isTrue, reason: result.failureOrNull?.message);
    final detail = result.valueOrNull!;
    expect(detail.category.id, 'cat_electronics');
    expect(detail.ancestors, isEmpty);
    expect(detail.category.children, isNotEmpty);
    expect(
      detail.category.children.any((c) => c.id == 'cat_electronics_phones'),
      isTrue,
    );
  });

  test('GetCategoryDetail deep nesting includes ancestor chain', () async {
    final result = await harness.getCategoryDetail(
      const GetCategoryDetailParams('cat_electronics_phones_cases'),
    );

    final detail = result.valueOrNull!;
    expect(detail.category.name, 'Phone Cases');
    expect(detail.ancestors.map((c) => c.id), [
      'cat_electronics',
      'cat_electronics_phones',
    ]);
  });

  test('GetCategoryDetail missing id → NotFoundFailure', () async {
    final result = await harness.getCategoryDetail(
      const GetCategoryDetailParams('cat_does_not_exist'),
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<NotFoundFailure>());
  });
}

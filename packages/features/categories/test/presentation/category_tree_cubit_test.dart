import 'package:bloc_test/bloc_test.dart';
import 'package:categories/categories.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/categories_test_harness.dart';

void main() {
  late CategoriesTestHarness harness;

  setUp(() {
    harness = CategoriesTestHarness.create();
  });

  blocTest<CategoryTreeCubit, CategoryTreeState>(
    'load emits loading then loaded roots',
    build: () => harness.createTreeCubit(),
    act: (cubit) => cubit.load(),
    expect: () => [
      const CategoryTreeLoading(),
      isA<CategoryTreeLoaded>()
          .having((s) => s.focusPath, 'focusPath', isEmpty)
          .having((s) => s.visibleCategories, 'visible', isNotEmpty)
          .having(
            (s) => s.visibleCategories.every((c) => c.isRoot),
            'all roots',
            isTrue,
          ),
    ],
  );

  blocTest<CategoryTreeCubit, CategoryTreeState>(
    'drillInto shows children in place',
    build: () => harness.createTreeCubit(),
    act: (cubit) async {
      await cubit.load();
      cubit.drillInto('cat_electronics');
    },
    expect: () => [
      const CategoryTreeLoading(),
      isA<CategoryTreeLoaded>().having((s) => s.focusPath, 'focus', isEmpty),
      isA<CategoryTreeLoaded>()
          .having((s) => s.focusPath.map((c) => c.id).toList(), 'path', [
            'cat_electronics',
          ])
          .having(
            (s) => s.visibleCategories.any(
              (c) => c.id == 'cat_electronics_phones',
            ),
            'phones visible',
            isTrue,
          ),
    ],
  );
}

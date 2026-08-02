import 'package:categories/categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/products.dart';

import '../helpers/categories_test_harness.dart';

void main() {
  late CategoriesTestHarness harness;

  setUp(() {
    harness = CategoriesTestHarness.create();
  });

  testWidgets('detail hosts ProductListScreen filtered by category', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CategoryDetailScreen(
          categoryId: 'cat_apparel',
          detailCubit: harness.createDetailCubit(),
          listBloc: harness.createListBloc(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Apparel'), findsWidgets);
    expect(find.byType(ProductListScreen), findsOneWidget);
    expect(find.byType(ProductCard), findsWidgets);
    expect(find.byType(CategoryBreadcrumb), findsOneWidget);
  });

  testWidgets('detail shows empty products for leaf with no seeded SKUs', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CategoryDetailScreen(
          categoryId: 'cat_electronics_phones_cases',
          detailCubit: harness.createDetailCubit(),
          listBloc: harness.createListBloc(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Phone Cases'), findsWidgets);
    expect(find.text('No products found'), findsOneWidget);
  });
}

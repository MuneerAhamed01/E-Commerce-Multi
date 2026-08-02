import 'package:categories/categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/categories_test_harness.dart';

void main() {
  late CategoriesTestHarness harness;

  setUp(() {
    harness = CategoriesTestHarness.create();
  });

  testWidgets('browse screen loads category grid tiles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CategoryBrowseScreen(treeCubit: harness.createTreeCubit()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Categories'), findsOneWidget);
    expect(find.byType(CategoryGridTile), findsWidgets);
    expect(find.text('Apparel'), findsOneWidget);
    expect(find.text('Electronics'), findsOneWidget);
  });
}

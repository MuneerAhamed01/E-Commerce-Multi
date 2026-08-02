import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/products.dart';

import '../helpers/products_test_harness.dart';

void main() {
  late ProductsTestHarness harness;

  setUp(() {
    harness = ProductsTestHarness.create();
  });

  testWidgets('list screen loads a page of product cards', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ProductListScreen(listBloc: harness.createListBloc())),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Products'), findsOneWidget);
    expect(find.byType(ProductCard), findsWidgets);
  });
}

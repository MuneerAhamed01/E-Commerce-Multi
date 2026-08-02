import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/products.dart';
import 'package:search/search.dart';

import '../helpers/search_test_harness.dart';

void main() {
  late SearchTestHarness harness;

  setUp(() {
    harness = SearchTestHarness.create();
  });

  testWidgets('zero results shows clear-filters CTA when filters active', (
    tester,
  ) async {
    final bloc = harness.createResultsBloc();
    await tester.pumpWidget(
      MaterialApp(
        home: SearchResultsScreen(query: 'classic', resultsBloc: bloc),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    bloc.add(
      const SearchResultsFilterApplied(
        SearchFilter(minPriceMinor: 0, maxPriceMinor: 1, minRating: 5),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('No results'), findsOneWidget);
    expect(find.text('Clear filters'), findsOneWidget);
  });

  testWidgets('results render ProductCards for matching query', (tester) async {
    final token = harness.store.products.first.name.split(' ').first;

    await tester.pumpWidget(
      MaterialApp(
        home: SearchResultsScreen(
          query: token,
          resultsBloc: harness.createResultsBloc(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(ProductCard), findsWidgets);
  });
}

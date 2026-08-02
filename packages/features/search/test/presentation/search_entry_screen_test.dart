import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:search/search.dart';

import '../helpers/search_test_harness.dart';

void main() {
  late SearchTestHarness harness;

  setUp(() {
    harness = SearchTestHarness.create();
  });

  testWidgets('entry shows trending when query empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SearchEntryScreen(searchBloc: harness.createSearchBloc()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Trending'), findsOneWidget);
    expect(find.text('classic'), findsOneWidget);
  });

  testWidgets('typing shows suggestions after AppSearchBar debounce', (
    tester,
  ) async {
    final token = harness.store.products.first.name.split(' ').first;

    await tester.pumpWidget(
      MaterialApp(
        home: SearchEntryScreen(searchBloc: harness.createSearchBloc()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.enterText(find.byType(TextField), token);
    // AppSearchBar default debounce is 350ms.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(ListTile), findsWidgets);
  });
}

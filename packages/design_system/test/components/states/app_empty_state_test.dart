import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('shows the title and a default illustration icon', (
    tester,
  ) async {
    await pumpApp(tester, const AppEmptyState(title: 'Your wishlist is empty'));

    expect(find.text('Your wishlist is empty'), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });

  testWidgets('shows the optional message', (tester) async {
    await pumpApp(
      tester,
      const AppEmptyState(
        title: 'No results',
        message: 'Try a different search.',
      ),
    );

    expect(find.text('Try a different search.'), findsOneWidget);
  });

  testWidgets('a custom illustration overrides the default icon', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const AppEmptyState(
        title: 'No results',
        illustration: Icon(Icons.search_off),
      ),
    );

    expect(find.byIcon(Icons.search_off), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsNothing);
  });

  testWidgets('shows a CTA button that invokes onCtaPressed', (tester) async {
    var tapped = false;
    await pumpApp(
      tester,
      AppEmptyState(
        title: 'No results',
        ctaLabel: 'Browse products',
        onCtaPressed: () => tapped = true,
      ),
    );

    await tester.tap(find.text('Browse products'));
    expect(tapped, isTrue);
  });

  test('asserts ctaLabel and onCtaPressed are provided together', () {
    expect(
      () => AppEmptyState(title: 'No results', ctaLabel: 'Retry'),
      throwsAssertionError,
    );
    expect(
      () => AppEmptyState(title: 'No results', onCtaPressed: () {}),
      throwsAssertionError,
    );
  });
}

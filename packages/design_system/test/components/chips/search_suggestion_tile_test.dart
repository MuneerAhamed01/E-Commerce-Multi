import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('shows title, subtitle, and invokes onTap', (tester) async {
    var tapped = false;
    await pumpApp(
      tester,
      AppSearchSuggestionTile(
        title: 'Running Shoes',
        subtitle: 'Footwear',
        onTap: () => tapped = true,
      ),
    );

    expect(find.text('Running Shoes'), findsOneWidget);
    expect(find.text('Footwear'), findsOneWidget);

    await tester.tap(find.text('Running Shoes'));
    expect(tapped, isTrue);
  });

  testWidgets('defaults to the icon matching its kind', (tester) async {
    await pumpApp(
      tester,
      AppSearchSuggestionTile(
        title: 'Shoes',
        kind: AppSearchSuggestionKind.category,
        onTap: () {},
      ),
    );

    expect(find.byIcon(Icons.category_outlined), findsOneWidget);
  });

  testWidgets('a custom leading widget overrides the default icon', (
    tester,
  ) async {
    await pumpApp(
      tester,
      AppSearchSuggestionTile(
        title: 'Shoes',
        kind: AppSearchSuggestionKind.product,
        leading: const Icon(Icons.star),
        onTap: () {},
      ),
    );

    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2_outlined), findsNothing);
  });
}

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('invokes onTap when pressed', (tester) async {
    var tapped = false;
    await pumpApp(
      tester,
      AppRecentSearchChip(label: 'running shoes', onTap: () => tapped = true),
    );

    await tester.tap(find.text('running shoes'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('shows a delete affordance only when onRemove is provided', (
    tester,
  ) async {
    await pumpApp(
      tester,
      AppRecentSearchChip(label: 'running shoes', onTap: () {}),
    );
    expect(find.byIcon(Icons.clear), findsNothing);

    var removed = false;
    await pumpApp(
      tester,
      AppRecentSearchChip(
        label: 'running shoes',
        onTap: () {},
        onRemove: () => removed = true,
      ),
    );
    expect(find.byIcon(Icons.clear), findsOneWidget);

    await tester.tap(find.byIcon(Icons.clear));
    expect(removed, isTrue);
  });
}

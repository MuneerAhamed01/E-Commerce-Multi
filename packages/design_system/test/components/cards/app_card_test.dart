import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('renders its child', (tester) async {
    await pumpApp(tester, const AppCard(child: Text('Card content')));

    expect(find.text('Card content'), findsOneWidget);
  });

  testWidgets('is not tappable without onTap', (tester) async {
    await pumpApp(tester, const AppCard(child: Text('Card content')));

    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets('invokes onTap when tapped', (tester) async {
    var tapped = false;
    await pumpApp(
      tester,
      AppCard(onTap: () => tapped = true, child: const Text('Card content')),
    );

    await tester.tap(find.text('Card content'));
    expect(tapped, isTrue);
  });

  testWidgets('outlined variant draws a border', (tester) async {
    await pumpApp(
      tester,
      const AppCard(
        variant: AppCardVariant.outlined,
        child: Text('Card content'),
      ),
    );

    final ink = tester.widget<Ink>(find.byType(Ink));
    final decoration = ink.decoration as BoxDecoration?;
    expect(decoration?.border, isNotNull);
  });

  testWidgets('flat variant has neither shadow nor border', (tester) async {
    await pumpApp(
      tester,
      const AppCard(variant: AppCardVariant.flat, child: Text('Card content')),
    );

    final ink = tester.widget<Ink>(find.byType(Ink));
    final decoration = ink.decoration as BoxDecoration?;
    expect(decoration?.border, isNull);
    expect(decoration?.boxShadow, isNull);
  });
}

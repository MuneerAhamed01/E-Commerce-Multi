import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('mini variant renders an icon-only circular FAB', (tester) async {
    var tapped = false;
    await pumpApp(
      tester,
      AppFloatingActionButton(icon: Icons.add, onPressed: () => tapped = true),
    );

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Create Product'), findsNothing);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('extended variant renders the icon and label', (tester) async {
    await pumpApp(
      tester,
      AppFloatingActionButton(
        icon: Icons.add,
        label: 'Create Product',
        variant: AppFabVariant.extended,
        onPressed: () {},
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Create Product'), findsOneWidget);
  });

  test('asserts that extended variant requires a label', () {
    expect(
      () => AppFloatingActionButton(
        icon: Icons.add,
        variant: AppFabVariant.extended,
        onPressed: () {},
      ),
      throwsAssertionError,
    );
  });
}

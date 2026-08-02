import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('invokes onPressed when tapped', (tester) async {
    var tapped = false;
    await pumpApp(
      tester,
      AppIconButton(
        icon: Icons.favorite_border,
        tooltip: 'Add to wishlist',
        onPressed: () => tapped = true,
      ),
    );

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('exposes the tooltip for accessibility', (tester) async {
    await pumpApp(
      tester,
      AppIconButton(
        icon: Icons.favorite_border,
        tooltip: 'Add to wishlist',
        onPressed: () {},
      ),
    );

    expect(find.byTooltip('Add to wishlist'), findsOneWidget);
  });

  testWidgets('is disabled when onPressed is null', (tester) async {
    await pumpApp(
      tester,
      const AppIconButton(
        icon: Icons.favorite_border,
        tooltip: 'Add to wishlist',
        onPressed: null,
      ),
    );

    final button = tester.widget<IconButton>(find.byType(IconButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('renders for the filled and outline variants', (tester) async {
    for (final variant in AppIconButtonVariant.values) {
      await pumpApp(
        tester,
        AppIconButton(
          icon: Icons.settings,
          tooltip: 'Settings',
          onPressed: () {},
          variant: variant,
        ),
      );
      expect(find.byIcon(Icons.settings), findsOneWidget);
    }
  });
}

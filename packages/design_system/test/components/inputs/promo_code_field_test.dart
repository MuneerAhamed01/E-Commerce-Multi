import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('applies the typed code via onApply', (tester) async {
    String? applied;
    await pumpApp(tester, AppPromoCodeField(onApply: (code) => applied = code));

    await tester.enterText(find.byType(TextFormField), 'SAVE10');
    await tester.tap(find.text('Apply'));
    await tester.pump();

    expect(applied, 'SAVE10');
  });

  testWidgets('does not call onApply with an empty/whitespace-only code', (
    tester,
  ) async {
    var callCount = 0;
    await pumpApp(tester, AppPromoCodeField(onApply: (_) => callCount++));

    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.tap(find.text('Apply'));
    await tester.pump();

    expect(callCount, 0);
  });

  testWidgets('shows the applied-code success state and allows removal', (
    tester,
  ) async {
    var removed = false;
    await pumpApp(
      tester,
      AppPromoCodeField(
        onApply: (_) {},
        appliedCode: 'SAVE10',
        onRemove: () => removed = true,
      ),
    );

    expect(find.text('"SAVE10" applied'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);

    await tester.tap(find.byIcon(Icons.close));
    expect(removed, isTrue);
  });

  testWidgets('surfaces an error via the text field when errorText is set', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const AppPromoCodeField(onApply: _noopApply, errorText: 'Invalid code'),
    );

    expect(find.text('Invalid code'), findsOneWidget);
  });
}

void _noopApply(String _) {}

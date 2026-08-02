import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('tapping increment reports value + 1 via onChanged', (
    tester,
  ) async {
    int? reported;
    await pumpApp(
      tester,
      AppQuantityStepper(value: 2, onChanged: (v) => reported = v),
    );

    await tester.tap(find.byIcon(Icons.add));
    expect(reported, 3);
  });

  testWidgets('tapping decrement reports value - 1 via onChanged', (
    tester,
  ) async {
    int? reported;
    await pumpApp(
      tester,
      AppQuantityStepper(value: 2, onChanged: (v) => reported = v),
    );

    await tester.tap(find.byIcon(Icons.remove));
    expect(reported, 1);
  });

  testWidgets('disables the decrement button at min', (tester) async {
    await pumpApp(
      tester,
      AppQuantityStepper(value: 1, min: 1, onChanged: (_) {}),
    );

    final buttons = tester.widgetList<IconButton>(find.byType(IconButton));
    final decrementButton = buttons.firstWhere(
      (b) => (b.icon as Icon).icon == Icons.remove,
    );
    expect(decrementButton.onPressed, isNull);
  });

  testWidgets('disables the increment button at max', (tester) async {
    await pumpApp(
      tester,
      AppQuantityStepper(value: 5, max: 5, onChanged: (_) {}),
    );

    final buttons = tester.widgetList<IconButton>(find.byType(IconButton));
    final incrementButton = buttons.firstWhere(
      (b) => (b.icon as Icon).icon == Icons.add,
    );
    expect(incrementButton.onPressed, isNull);
  });

  testWidgets('disables both buttons when enabled is false', (tester) async {
    await pumpApp(
      tester,
      AppQuantityStepper(value: 2, enabled: false, onChanged: (_) {}),
    );

    final buttons = tester.widgetList<IconButton>(find.byType(IconButton));
    expect(buttons.every((b) => b.onPressed == null), isTrue);
  });

  test('asserts min <= max', () {
    expect(
      () => AppQuantityStepper(value: 1, min: 5, max: 1, onChanged: (_) {}),
      throwsAssertionError,
    );
  });
}

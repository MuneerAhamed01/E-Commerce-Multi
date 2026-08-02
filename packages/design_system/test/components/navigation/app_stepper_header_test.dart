import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  const steps = ['Address', 'Shipping', 'Payment', 'Review'];

  testWidgets('shows every step label', (tester) async {
    await pumpApp(tester, AppStepperHeader(steps: steps, currentStep: 1));

    for (final step in steps) {
      expect(find.text(step), findsOneWidget);
    }
  });

  testWidgets('shows a checkmark for steps before the current one', (
    tester,
  ) async {
    await pumpApp(tester, AppStepperHeader(steps: steps, currentStep: 2));

    expect(find.byIcon(Icons.check), findsNWidgets(2));
  });

  testWidgets('shows a number for the current and future steps', (
    tester,
  ) async {
    await pumpApp(tester, AppStepperHeader(steps: steps, currentStep: 0));

    expect(find.byIcon(Icons.check), findsNothing);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  test('asserts currentStep is non-negative', () {
    expect(
      () => AppStepperHeader(steps: steps, currentStep: -1),
      throwsAssertionError,
    );
  });

  test('asserts currentStep is a valid index into steps', () {
    expect(
      () => AppStepperHeader(steps: steps, currentStep: 10),
      throwsAssertionError,
    );
  });
}

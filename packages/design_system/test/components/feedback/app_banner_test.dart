import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('shows the message and default info icon', (tester) async {
    await pumpApp(
      tester,
      const AppBanner(message: 'Scheduled maintenance tonight.'),
    );

    expect(find.text('Scheduled maintenance tonight.'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });

  testWidgets('shows a warning icon for the warning variant', (tester) async {
    await pumpApp(
      tester,
      const AppBanner(message: 'Heads up', variant: AppBannerVariant.warning),
    );

    expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
  });

  testWidgets('shows an error icon for the error variant', (tester) async {
    await pumpApp(
      tester,
      const AppBanner(message: 'Failed', variant: AppBannerVariant.error),
    );

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('hides the dismiss button when onDismiss is null', (
    tester,
  ) async {
    await pumpApp(tester, const AppBanner(message: 'Info'));

    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('shows a dismiss button that invokes onDismiss', (tester) async {
    var dismissed = false;
    await pumpApp(
      tester,
      AppBanner(message: 'Info', onDismiss: () => dismissed = true),
    );

    await tester.tap(find.byIcon(Icons.close));
    expect(dismissed, isTrue);
  });
}

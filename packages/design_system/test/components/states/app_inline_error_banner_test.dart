import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('shows the message', (tester) async {
    await pumpApp(
      tester,
      const AppInlineErrorBanner(message: 'Something went wrong'),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
  });

  testWidgets('hides the dismiss button when onDismiss is null', (
    tester,
  ) async {
    await pumpApp(tester, const AppInlineErrorBanner(message: 'Error'));

    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('shows a dismiss button that invokes onDismiss', (tester) async {
    var dismissed = false;
    await pumpApp(
      tester,
      AppInlineErrorBanner(message: 'Error', onDismiss: () => dismissed = true),
    );

    await tester.tap(find.byIcon(Icons.close));
    expect(dismissed, isTrue);
  });
}

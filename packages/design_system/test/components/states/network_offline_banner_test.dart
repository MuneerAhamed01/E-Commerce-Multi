import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('shows the default offline message and icon', (tester) async {
    await pumpApp(tester, const AppNetworkOfflineBanner());

    expect(find.text("You're offline"), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
  });

  testWidgets('shows a custom message when provided', (tester) async {
    await pumpApp(
      tester,
      const AppNetworkOfflineBanner(message: 'Connection lost'),
    );

    expect(find.text('Connection lost'), findsOneWidget);
  });
}

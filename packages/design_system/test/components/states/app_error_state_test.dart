import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('shows the title, message, and an error icon', (tester) async {
    await pumpApp(
      tester,
      const AppErrorState(
        title: 'Something went wrong',
        message: 'Please try again later.',
      ),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Please try again later.'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('hides the retry action when onRetry is null', (tester) async {
    await pumpApp(
      tester,
      const AppErrorState(title: 'Error', message: 'Failed'),
    );

    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('shows a retry action that invokes onRetry', (tester) async {
    var retried = false;
    await pumpApp(
      tester,
      AppErrorState(
        title: 'Error',
        message: 'Failed',
        onRetry: () => retried = true,
      ),
    );

    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });
}

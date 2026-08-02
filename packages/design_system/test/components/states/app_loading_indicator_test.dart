import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('small size renders only the spinner, no message', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const AppLoadingIndicator(
        size: AppLoadingIndicatorSize.small,
        message: 'Loading…',
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading…'), findsNothing);
  });

  testWidgets('medium size shows the optional message', (tester) async {
    await pumpApp(
      tester,
      const AppLoadingIndicator(message: 'Loading orders…'),
    );

    expect(find.text('Loading orders…'), findsOneWidget);
  });

  testWidgets('overlay size dims the background behind the spinner', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const AppLoadingIndicator(size: AppLoadingIndicatorSize.overlay),
    );

    expect(
      find.byWidgetPredicate(
        (widget) => widget is ColoredBox && widget.color.a > 0,
      ),
      findsOneWidget,
    );
  });
}

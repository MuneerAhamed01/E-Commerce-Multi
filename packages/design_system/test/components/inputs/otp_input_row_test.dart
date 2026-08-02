import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('renders one text field per digit of length', (tester) async {
    await pumpApp(tester, AppOtpInputRow(length: 4, onCompleted: (_) {}));

    expect(find.byType(TextField), findsNWidgets(4));
  });

  testWidgets(
    'auto-advances focus and calls onCompleted once all boxes are filled',
    (tester) async {
      String? completedCode;
      await pumpApp(
        tester,
        AppOtpInputRow(length: 4, onCompleted: (code) => completedCode = code),
      );

      final fields = find.byType(TextField);
      for (var i = 0; i < 4; i++) {
        await tester.enterText(fields.at(i), '$i');
        await tester.pump();
      }

      expect(completedCode, '0123');
    },
  );

  testWidgets('renders without error when hasError toggles on', (tester) async {
    await pumpApp(tester, AppOtpInputRow(length: 4, onCompleted: (_) {}));

    await pumpApp(
      tester,
      AppOtpInputRow(length: 4, hasError: true, onCompleted: (_) {}),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(TextField), findsNWidgets(4));
  });
}

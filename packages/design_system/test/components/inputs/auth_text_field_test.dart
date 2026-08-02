import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('renders the label and forwards the given autofill hints', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const AppAuthTextField(
        label: 'Password',
        obscureText: true,
        autofillHints: [AutofillHints.password],
      ),
    );

    expect(find.text('Password'), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.autofillHints, [AutofillHints.password]);
  });

  testWidgets('forwards typed text via onChanged', (tester) async {
    String? lastValue;
    await pumpApp(
      tester,
      AppAuthTextField(label: 'Email', onChanged: (value) => lastValue = value),
    );

    await tester.enterText(find.byType(TextFormField), 'user@test.com');
    expect(lastValue, 'user@test.com');
  });
}

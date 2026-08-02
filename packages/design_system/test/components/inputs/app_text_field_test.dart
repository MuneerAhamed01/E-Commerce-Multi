import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('shows label, hint, and forwards typed text via onChanged', (
    tester,
  ) async {
    String? lastValue;
    await pumpApp(
      tester,
      AppTextField(
        label: 'Email',
        hint: 'you@example.com',
        onChanged: (value) => lastValue = value,
      ),
    );

    expect(find.text('Email'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'hello@test.com');
    expect(lastValue, 'hello@test.com');
  });

  testWidgets('shows externally-supplied error text', (tester) async {
    await pumpApp(
      tester,
      const AppTextField(label: 'Email', errorText: 'Invalid email'),
    );

    expect(find.text('Invalid email'), findsOneWidget);
  });

  testWidgets('is disabled when enabled is false', (tester) async {
    await pumpApp(tester, const AppTextField(label: 'Email', enabled: false));

    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.enabled, isFalse);
  });

  testWidgets('forces maxLines to 1 when obscureText is true', (tester) async {
    await pumpApp(
      tester,
      const AppTextField(label: 'Password', obscureText: true, maxLines: 5),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.maxLines, 1);
  });
}

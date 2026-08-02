import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('invokes onPressed when tapped', (tester) async {
    var tapped = false;
    await pumpApp(
      tester,
      AppTextLinkButton(
        label: 'Forgot password?',
        onPressed: () => tapped = true,
      ),
    );

    await tester.tap(find.text('Forgot password?'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('renders disabled when onPressed is null', (tester) async {
    await pumpApp(
      tester,
      const AppTextLinkButton(label: 'Forgot password?', onPressed: null),
    );

    final button = tester.widget<TextButton>(find.byType(TextButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('underlines the label text', (tester) async {
    await pumpApp(
      tester,
      AppTextLinkButton(label: 'View all', onPressed: () {}),
    );

    final text = tester.widget<Text>(find.text('View all'));
    expect(text.style?.decoration, TextDecoration.underline);
  });
}

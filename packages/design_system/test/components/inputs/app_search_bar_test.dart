import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('debounces onChanged until typing stops', (tester) async {
    final values = <String>[];
    await pumpApp(tester, AppSearchBar(onChanged: values.add));

    await tester.enterText(find.byType(TextField), 'sh');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), 'shoe');
    expect(values, isEmpty);

    await tester.pump(const Duration(milliseconds: 400));
    expect(values, ['shoe']);
  });

  testWidgets('onSubmitted fires immediately without waiting for debounce', (
    tester,
  ) async {
    String? submitted;
    await pumpApp(
      tester,
      AppSearchBar(onSubmitted: (value) => submitted = value),
    );

    await tester.enterText(find.byType(TextField), 'shoes');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    expect(submitted, 'shoes');
  });

  testWidgets('shows a clear button once text is entered and clears on tap', (
    tester,
  ) async {
    await pumpApp(tester, AppSearchBar(onChanged: (_) {}));

    expect(find.byIcon(Icons.clear), findsNothing);

    await tester.enterText(find.byType(TextField), 'shoes');
    await tester.pump();
    expect(find.byIcon(Icons.clear), findsOneWidget);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(find.byIcon(Icons.clear), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '',
    );
  });
}

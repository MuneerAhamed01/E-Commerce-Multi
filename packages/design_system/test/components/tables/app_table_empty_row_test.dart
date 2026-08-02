import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('shows the message', (tester) async {
    await pumpApp(
      tester,
      const AppTableEmptyRow(message: 'No products match these filters'),
    );

    expect(find.text('No products match these filters'), findsOneWidget);
  });

  testWidgets('hides the CTA when ctaLabel is null', (tester) async {
    await pumpApp(tester, const AppTableEmptyRow(message: 'No data'));

    expect(find.text('Clear filters'), findsNothing);
  });

  testWidgets('shows a CTA that invokes onCtaPressed', (tester) async {
    var tapped = false;
    await pumpApp(
      tester,
      AppTableEmptyRow(
        message: 'No data',
        ctaLabel: 'Clear filters',
        onCtaPressed: () => tapped = true,
      ),
    );

    await tester.tap(find.text('Clear filters'));
    expect(tapped, isTrue);
  });
}

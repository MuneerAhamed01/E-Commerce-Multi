import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('shows the title, rank, label, and value for each item', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const AppTopProductsTable(
        title: 'Top Products',
        valueLabel: 'Units Sold',
        items: [
          AppChartDatum(label: 'Running Shoes', value: 128),
          AppChartDatum(label: 'Yoga Mat', value: 96),
        ],
      ),
    );

    expect(find.text('Top Products'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Running Shoes'), findsOneWidget);
    expect(find.text('Yoga Mat'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);
    expect(find.text('96'), findsOneWidget);
    expect(find.text('Units Sold'), findsOneWidget);
  });

  testWidgets(
    'shows "No data available" and hides the value label when empty',
    (tester) async {
      await pumpApp(
        tester,
        const AppTopProductsTable(title: 'Top Products', items: []),
      );

      expect(find.text('No data available'), findsOneWidget);
      expect(find.text('Value'), findsNothing);
    },
  );
}

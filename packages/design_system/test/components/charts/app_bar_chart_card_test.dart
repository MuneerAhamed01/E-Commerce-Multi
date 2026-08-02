import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('shows the title and every datum label/value', (tester) async {
    await pumpApp(
      tester,
      const AppBarChartCard(
        title: 'Orders by Status',
        data: [
          AppChartDatum(label: 'Processing', value: 42),
          AppChartDatum(label: 'Shipped', value: 108),
        ],
      ),
    );

    expect(find.text('Orders by Status'), findsOneWidget);
    expect(find.text('Processing'), findsOneWidget);
    expect(find.text('Shipped'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('108'), findsOneWidget);
  });

  testWidgets('shows "No data available" when data is empty', (tester) async {
    await pumpApp(
      tester,
      const AppBarChartCard(title: 'Orders by Status', data: []),
    );

    expect(find.text('No data available'), findsOneWidget);
  });

  testWidgets('renders horizontal bars for the horizontal direction', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const AppBarChartCard(
        title: 'Orders by Status',
        direction: AppBarChartDirection.horizontal,
        data: [AppChartDatum(label: 'Processing', value: 42)],
      ),
    );

    expect(find.text('Processing'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
  });
}

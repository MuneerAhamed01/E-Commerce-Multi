import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('shows the title', (tester) async {
    await pumpApp(
      tester,
      const AppLineChartCard(
        title: 'Sales (Last 7 Days)',
        series: [
          AppChartSeries(label: 'Revenue', values: [1, 2, 3]),
        ],
      ),
    );

    expect(find.text('Sales (Last 7 Days)'), findsOneWidget);
  });

  testWidgets(
    'degrades to a "No data available" message when series is empty',
    (tester) async {
      await pumpApp(tester, const AppLineChartCard(title: 'Sales', series: []));

      expect(find.text('No data available'), findsOneWidget);
    },
  );

  testWidgets('degrades to "No data available" when every series is empty', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const AppLineChartCard(
        title: 'Sales',
        series: [AppChartSeries(label: 'Revenue', values: [])],
      ),
    );

    expect(find.text('No data available'), findsOneWidget);
  });

  testWidgets('renders a chart painter when data is present', (tester) async {
    await pumpApp(
      tester,
      const AppLineChartCard(
        title: 'Sales',
        series: [
          AppChartSeries(label: 'Revenue', values: [1, 5, 3]),
        ],
      ),
    );

    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.text('No data available'), findsNothing);
  });

  testWidgets('shows a legend only when there is more than one series', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const AppLineChartCard(
        title: 'Sales',
        series: [
          AppChartSeries(label: 'Revenue', values: [1, 2, 3]),
        ],
      ),
    );
    expect(find.text('Revenue'), findsNothing);

    await pumpApp(
      tester,
      const AppLineChartCard(
        title: 'Sales',
        series: [
          AppChartSeries(label: 'Revenue', values: [1, 2, 3]),
          AppChartSeries(label: 'Cost', values: [1, 1, 1]),
        ],
      ),
    );
    expect(find.text('Revenue'), findsOneWidget);
    expect(find.text('Cost'), findsOneWidget);
  });
}

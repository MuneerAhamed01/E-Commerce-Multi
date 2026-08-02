import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('shows the title and every segment label with its value', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const AppDonutChartCard(
        title: 'Orders by Status',
        segments: [
          AppChartSegment(label: 'Shipped', value: 60),
          AppChartSegment(label: 'Processing', value: 40),
        ],
      ),
    );

    expect(find.text('Orders by Status'), findsOneWidget);
    expect(find.text('Shipped (60)'), findsOneWidget);
    expect(find.text('Processing (40)'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('shows "No data available" when every segment is zero', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const AppDonutChartCard(
        title: 'Orders by Status',
        segments: [AppChartSegment(label: 'Shipped', value: 0)],
      ),
    );

    expect(find.text('No data available'), findsOneWidget);
  });

  testWidgets('shows "No data available" when segments is empty', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const AppDonutChartCard(title: 'Orders by Status', segments: []),
    );

    expect(find.text('No data available'), findsOneWidget);
  });
}

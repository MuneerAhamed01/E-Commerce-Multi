import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('shows the label and value', (tester) async {
    await pumpApp(
      tester,
      const AppKpiCard(label: 'Total Sales', value: r'$12,480'),
    );

    expect(find.text('Total Sales'), findsOneWidget);
    expect(find.text(r'$12,480'), findsOneWidget);
  });

  testWidgets('shows shimmer placeholders instead of content while loading', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const AppKpiCard(
        label: 'Total Sales',
        value: r'$12,480',
        isLoading: true,
      ),
    );

    expect(find.text('Total Sales'), findsNothing);
    expect(find.byType(AppShimmerPlaceholder), findsWidgets);
  });

  testWidgets(
    'shows the delta percentage with an upward icon for a positive trend',
    (tester) async {
      await pumpApp(
        tester,
        const AppKpiCard(
          label: 'Total Sales',
          value: r'$12,480',
          deltaPercent: 4.2,
          trend: AppKpiTrend.positive,
        ),
      );

      expect(find.text('4.2%'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    },
  );

  testWidgets('shows a downward icon for a negative trend', (tester) async {
    await pumpApp(
      tester,
      const AppKpiCard(
        label: 'Total Sales',
        value: r'$12,480',
        deltaPercent: -2.5,
        trend: AppKpiTrend.negative,
      ),
    );

    expect(find.text('2.5%'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
  });

  testWidgets('shows the optional leading icon', (tester) async {
    await pumpApp(
      tester,
      const AppKpiCard(
        label: 'Total Sales',
        value: r'$12,480',
        icon: Icons.trending_up,
      ),
    );

    expect(find.byIcon(Icons.trending_up), findsOneWidget);
  });
}

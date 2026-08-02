import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  const items = [
    AppSideNavItem(
      icon: Icons.dashboard_outlined,
      label: 'Dashboard',
      route: '/dashboard',
    ),
    AppSideNavItem(
      icon: Icons.inventory_2_outlined,
      label: 'Products',
      route: '/products',
    ),
  ];

  testWidgets('shows every destination label in expanded mode', (tester) async {
    await pumpApp(
      tester,
      AppSideNav(items: items, currentRoute: '/dashboard', onSelect: (_) {}),
    );

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
  });

  testWidgets('selecting a destination invokes onSelect with its route', (
    tester,
  ) async {
    String? selectedRoute;
    await pumpApp(
      tester,
      AppSideNav(
        items: items,
        currentRoute: '/dashboard',
        onSelect: (route) => selectedRoute = route,
      ),
    );

    await tester.tap(find.text('Products'));
    expect(selectedRoute, '/products');
  });

  testWidgets('collapsed mode renders a non-extended rail', (tester) async {
    await pumpApp(
      tester,
      AppSideNav(
        items: items,
        currentRoute: '/dashboard',
        mode: AppSideNavMode.collapsed,
        onSelect: (_) {},
      ),
    );

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.extended, isFalse);
  });

  testWidgets('has no selection when currentRoute matches no item', (
    tester,
  ) async {
    await pumpApp(
      tester,
      AppSideNav(items: items, currentRoute: '/unknown', onSelect: (_) {}),
    );

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.selectedIndex, isNull);
  });
}

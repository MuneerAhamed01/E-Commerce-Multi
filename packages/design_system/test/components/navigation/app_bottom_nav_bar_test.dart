import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  const items = [
    AppBottomNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    AppBottomNavItem(
      icon: Icons.shopping_cart_outlined,
      label: 'Cart',
      badgeCount: 3,
    ),
  ];

  testWidgets('shows every destination label', (tester) async {
    await pumpApp(
      tester,
      AppBottomNavBar(items: items, currentIndex: 0, onTap: (_) {}),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
  });

  testWidgets('tapping a destination invokes onTap with its index', (
    tester,
  ) async {
    int? tappedIndex;
    await pumpApp(
      tester,
      AppBottomNavBar(
        items: items,
        currentIndex: 0,
        onTap: (i) => tappedIndex = i,
      ),
    );

    await tester.tap(find.text('Cart'));
    expect(tappedIndex, 1);
  });

  testWidgets('shows the selected icon for the current destination', (
    tester,
  ) async {
    await pumpApp(
      tester,
      AppBottomNavBar(items: items, currentIndex: 0, onTap: (_) {}),
    );

    expect(find.byIcon(Icons.home), findsOneWidget);
  });

  testWidgets('overlays a badge when badgeCount is positive', (tester) async {
    await pumpApp(
      tester,
      AppBottomNavBar(items: items, currentIndex: 0, onTap: (_) {}),
    );

    expect(find.byType(Badge), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });
}

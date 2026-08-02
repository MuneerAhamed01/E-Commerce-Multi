import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('shows every tab label', (tester) async {
    await pumpApp(
      tester,
      AppTabBar(
        tabs: const ['All', 'Open', 'Resolved'],
        currentIndex: 0,
        onTap: (_) {},
      ),
    );

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Resolved'), findsOneWidget);
  });

  testWidgets('marks the currentIndex tab as selected', (tester) async {
    await pumpApp(
      tester,
      AppTabBar(
        tabs: const ['All', 'Open', 'Resolved'],
        currentIndex: 1,
        onTap: (_) {},
      ),
    );

    final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));
    expect(chips.elementAt(1).selected, isTrue);
    expect(chips.elementAt(0).selected, isFalse);
  });

  testWidgets('tapping a tab invokes onTap with its index', (tester) async {
    int? tappedIndex;
    await pumpApp(
      tester,
      AppTabBar(
        tabs: const ['All', 'Open', 'Resolved'],
        currentIndex: 0,
        onTap: (i) => tappedIndex = i,
      ),
    );

    await tester.tap(find.text('Resolved'));
    expect(tappedIndex, 2);
  });
}

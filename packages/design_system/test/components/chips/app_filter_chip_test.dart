import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('reports the toggled selection state on tap', (tester) async {
    bool? toggledTo;
    await pumpApp(
      tester,
      AppFilterChip(
        label: 'In Stock',
        selected: false,
        onTap: (value) => toggledTo = value,
      ),
    );

    await tester.tap(find.text('In Stock'));
    await tester.pump();

    expect(toggledTo, isTrue);
  });

  testWidgets('reflects the selected state visually', (tester) async {
    await pumpApp(
      tester,
      AppFilterChip(label: 'In Stock', selected: true, onTap: (_) {}),
    );

    final chip = tester.widget<FilterChip>(find.byType(FilterChip));
    expect(chip.selected, isTrue);
  });
}

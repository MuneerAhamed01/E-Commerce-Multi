import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('renders nothing when filters is empty', (tester) async {
    await pumpApp(
      tester,
      AppActiveFilterChipRow(filters: const [], onRemove: (_) {}),
    );

    expect(find.byType(InputChip), findsNothing);
    expect(find.byType(SizedBox), findsWidgets);
  });

  testWidgets('renders a chip per filter and removes on delete', (
    tester,
  ) async {
    String? removedId;
    await pumpApp(
      tester,
      AppActiveFilterChipRow(
        filters: const [
          AppActiveFilter(id: 'brand-nike', label: 'Nike'),
          AppActiveFilter(id: 'color-red', label: 'Red'),
        ],
        onRemove: (id) => removedId = id,
      ),
    );

    expect(find.text('Nike'), findsOneWidget);
    expect(find.text('Red'), findsOneWidget);

    final deleteButtons = find.byIcon(Icons.clear);
    await tester.tap(deleteButtons.first);
    await tester.pump();

    expect(removedId, 'brand-nike');
  });

  testWidgets('shows a "Clear all" action only when onClearAll is provided', (
    tester,
  ) async {
    await pumpApp(
      tester,
      AppActiveFilterChipRow(
        filters: const [AppActiveFilter(id: '1', label: 'Nike')],
        onRemove: (_) {},
      ),
    );
    expect(find.text('Clear all'), findsNothing);

    var cleared = false;
    await pumpApp(
      tester,
      AppActiveFilterChipRow(
        filters: const [AppActiveFilter(id: '1', label: 'Nike')],
        onRemove: (_) {},
        onClearAll: () => cleared = true,
      ),
    );
    expect(find.text('Clear all'), findsOneWidget);

    await tester.tap(find.text('Clear all'));
    expect(cleared, isTrue);
  });
}

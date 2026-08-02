import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('shows the selected count', (tester) async {
    await pumpApp(
      tester,
      const AppBulkActionToolbar(selectedCount: 3, actions: []),
    );

    expect(find.text('3 selected'), findsOneWidget);
  });

  testWidgets('renders an icon button for actions with an icon', (
    tester,
  ) async {
    var tapped = false;
    await pumpApp(
      tester,
      AppBulkActionToolbar(
        selectedCount: 1,
        actions: [
          AppBulkAction(
            label: 'Delete',
            icon: Icons.delete_outline,
            onPressed: () => tapped = true,
          ),
        ],
      ),
    );

    await tester.tap(find.byIcon(Icons.delete_outline));
    expect(tapped, isTrue);
  });

  testWidgets('renders a text link button for actions without an icon', (
    tester,
  ) async {
    var tapped = false;
    await pumpApp(
      tester,
      AppBulkActionToolbar(
        selectedCount: 1,
        actions: [
          AppBulkAction(label: 'Archive', onPressed: () => tapped = true),
        ],
      ),
    );

    await tester.tap(find.text('Archive'));
    expect(tapped, isTrue);
  });

  testWidgets('shows a clear-selection button that invokes onClearSelection', (
    tester,
  ) async {
    var cleared = false;
    await pumpApp(
      tester,
      AppBulkActionToolbar(
        selectedCount: 1,
        actions: const [],
        onClearSelection: () => cleared = true,
      ),
    );

    await tester.tap(find.byIcon(Icons.close));
    expect(cleared, isTrue);
  });

  testWidgets('hides the clear-selection button when the callback is null', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const AppBulkActionToolbar(selectedCount: 1, actions: []),
    );

    expect(find.byIcon(Icons.close), findsNothing);
  });
}

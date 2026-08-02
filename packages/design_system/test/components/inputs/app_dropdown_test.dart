import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

enum _Status { pending, shipped, delivered }

void main() {
  testWidgets('shows the label and the selected item label', (tester) async {
    await pumpApp(
      tester,
      AppDropdown<_Status>(
        label: 'Status',
        value: _Status.shipped,
        items: const [
          AppDropdownItem(value: _Status.pending, label: 'Pending'),
          AppDropdownItem(value: _Status.shipped, label: 'Shipped'),
          AppDropdownItem(value: _Status.delivered, label: 'Delivered'),
        ],
        onChanged: (_) {},
      ),
    );

    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Shipped'), findsOneWidget);
  });

  testWidgets('selecting an item invokes onChanged with its value', (
    tester,
  ) async {
    _Status? selected;
    await pumpApp(
      tester,
      AppDropdown<_Status>(
        value: _Status.pending,
        items: const [
          AppDropdownItem(value: _Status.pending, label: 'Pending'),
          AppDropdownItem(value: _Status.delivered, label: 'Delivered'),
        ],
        onChanged: (value) => selected = value,
      ),
    );

    await tester.tap(find.byType(DropdownButtonFormField<_Status>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delivered').last);
    await tester.pumpAndSettle();

    expect(selected, _Status.delivered);
  });

  testWidgets('is disabled when enabled is false', (tester) async {
    await pumpApp(
      tester,
      AppDropdown<_Status>(
        items: const [
          AppDropdownItem(value: _Status.pending, label: 'Pending'),
        ],
        enabled: false,
        onChanged: (_) {},
      ),
    );

    final field = tester.widget<DropdownButtonFormField<_Status>>(
      find.byType(DropdownButtonFormField<_Status>),
    );
    expect(field.onChanged, isNull);
  });
}

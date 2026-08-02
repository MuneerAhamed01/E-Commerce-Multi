import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

const _address = Address(
  label: 'Home',
  line1: '123 Main St',
  city: 'Springfield',
  state: 'IL',
  postalCode: '62701',
  countryCode: 'US',
);

void main() {
  testWidgets('shows the address label and single-line summary', (
    tester,
  ) async {
    await pumpApp(tester, const AppAddressCard(address: _address));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text(_address.singleLine), findsOneWidget);
  });

  testWidgets('shows a "Default" badge when isDefault is true', (tester) async {
    await pumpApp(
      tester,
      const AppAddressCard(address: _address, isDefault: true),
    );

    expect(find.text('Default'), findsOneWidget);
  });

  testWidgets('selectable variant invokes onSelect when tapped', (
    tester,
  ) async {
    var selected = false;
    await pumpApp(
      tester,
      AppAddressCard(
        address: _address,
        variant: AppAddressCardVariant.selectable,
        onSelect: () => selected = true,
      ),
    );

    await tester.tap(find.text('Home'));
    expect(selected, isTrue);
  });

  testWidgets('shows a filled selection icon when isSelected is true', (
    tester,
  ) async {
    await pumpApp(
      tester,
      AppAddressCard(
        address: _address,
        variant: AppAddressCardVariant.selectable,
        isSelected: true,
        onSelect: () {},
      ),
    );

    expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
  });

  testWidgets('readonly variant shows no selection icon and is not tappable', (
    tester,
  ) async {
    await pumpApp(tester, const AppAddressCard(address: _address));

    expect(find.byIcon(Icons.radio_button_checked), findsNothing);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets('shows edit/delete actions when their callbacks are provided', (
    tester,
  ) async {
    var edited = false;
    var deleted = false;
    await pumpApp(
      tester,
      AppAddressCard(
        address: _address,
        onEdit: () => edited = true,
        onDelete: () => deleted = true,
      ),
    );

    await tester.tap(find.byIcon(Icons.edit_outlined));
    expect(edited, isTrue);

    await tester.tap(find.byIcon(Icons.delete_outline));
    expect(deleted, isTrue);
  });
}

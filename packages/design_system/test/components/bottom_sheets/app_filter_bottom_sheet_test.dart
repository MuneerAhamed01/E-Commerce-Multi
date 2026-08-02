import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const groups = [
    AppFilterGroup(
      title: 'Brand',
      options: [
        AppFilterOption(id: 'nike', label: 'Nike'),
        AppFilterOption(id: 'adidas', label: 'Adidas'),
      ],
    ),
  ];

  testWidgets('shows the group titles and chip labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => AppFilterBottomSheet.show(
              context,
              groups: groups,
              activeFilterIds: const {},
              onApply: (_) {},
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Brand'), findsOneWidget);
    expect(find.text('Nike'), findsOneWidget);
    expect(find.text('Adidas'), findsOneWidget);
  });

  testWidgets('toggling a chip and applying reports the selected ids', (
    tester,
  ) async {
    Set<String>? applied;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => AppFilterBottomSheet.show(
              context,
              groups: groups,
              activeFilterIds: const {},
              onApply: (ids) => applied = ids,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nike'));
    await tester.pump();

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(applied, {'nike'});
  });

  testWidgets('clear all empties the selection and invokes onClear', (
    tester,
  ) async {
    var cleared = false;
    Set<String>? applied;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => AppFilterBottomSheet.show(
              context,
              groups: groups,
              activeFilterIds: const {'nike'},
              onApply: (ids) => applied = ids,
              onClear: () => cleared = true,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear all'));
    await tester.pump();
    expect(cleared, isTrue);

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(applied, isEmpty);
  });
}

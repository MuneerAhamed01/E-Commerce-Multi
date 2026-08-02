import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

const _columns = [
  AppDataColumn(label: 'Name', sortable: true),
  AppDataColumn(label: 'Stock', numeric: true),
];

final _rows = [
  const AppDataRowData(id: '1', cells: [Text('Shoes'), Text('12')]),
  const AppDataRowData(id: '2', cells: [Text('Socks'), Text('40')]),
];

void main() {
  testWidgets('renders shimmer placeholders while loading', (tester) async {
    await pumpApp(
      tester,
      const AppDataTable(
        columns: _columns,
        state: ListViewLoading<AppDataRowData>(),
      ),
    );

    expect(find.byType(AppShimmerPlaceholder), findsWidgets);
    expect(find.byType(DataTable), findsNothing);
  });

  testWidgets('renders an error state with retry', (tester) async {
    var retried = false;
    await pumpApp(
      tester,
      AppDataTable(
        columns: _columns,
        state: const ListViewError<AppDataRowData>('Failed to load'),
        onRetry: () => retried = true,
      ),
    );

    expect(find.text('Failed to load'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('renders the empty message when there are no rows', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const AppDataTable(
        columns: _columns,
        state: ListViewEmpty<AppDataRowData>(),
        emptyMessage: 'No products match these filters',
      ),
    );

    expect(find.text('No products match these filters'), findsOneWidget);
  });

  testWidgets('renders columns and row cells when loaded', (tester) async {
    await pumpApp(
      tester,
      AppDataTable(
        columns: _columns,
        state: ListViewLoaded<AppDataRowData>(_rows),
      ),
    );

    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Stock'), findsOneWidget);
    expect(find.text('Shoes'), findsOneWidget);
    expect(find.text('Socks'), findsOneWidget);
  });

  testWidgets(
    'tapping a row invokes onRowTap with its id when not selectable',
    (tester) async {
      String? tappedId;
      await pumpApp(
        tester,
        AppDataTable(
          columns: _columns,
          state: ListViewLoaded<AppDataRowData>(_rows),
          onRowTap: (id) => tappedId = id,
        ),
      );

      await tester.tap(find.text('Shoes'));
      expect(tappedId, '1');
    },
  );

  testWidgets('selecting a row reports the updated selection set', (
    tester,
  ) async {
    Set<String>? reported;
    await pumpApp(
      tester,
      AppDataTable(
        columns: _columns,
        state: ListViewLoaded<AppDataRowData>(_rows),
        selectable: true,
        onSelectionChanged: (ids) => reported = ids,
      ),
    );

    final checkboxes = find.byType(Checkbox);
    // First checkbox is "select all"; row checkboxes follow.
    await tester.tap(checkboxes.at(1));
    expect(reported, {'1'});
  });

  testWidgets('sorting a sortable column invokes onSort', (tester) async {
    int? sortedColumnIndex;
    bool? sortedAscending;
    await pumpApp(
      tester,
      AppDataTable(
        columns: _columns,
        state: ListViewLoaded<AppDataRowData>(_rows),
        onSort: (columnIndex, ascending) {
          sortedColumnIndex = columnIndex;
          sortedAscending = ascending;
        },
      ),
    );

    await tester.tap(find.text('Name'));
    expect(sortedColumnIndex, 0);
    expect(sortedAscending, isNotNull);
  });
}

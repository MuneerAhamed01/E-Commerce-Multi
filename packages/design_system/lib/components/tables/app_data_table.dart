import 'package:flutter/material.dart';

import '../../state/list_view_state.dart';
import '../../tokens/app_spacing.dart';
import '../states/app_error_state.dart';
import '../states/shimmer_placeholder.dart';
import 'app_table_empty_row.dart';

/// A single column header in an [AppDataTable].
class AppDataColumn {
  const AppDataColumn({
    required this.label,
    this.sortable = false,
    this.numeric = false,
  });

  final String label;

  /// Whether tapping this column's header should invoke
  /// [AppDataTable.onSort].
  final bool sortable;

  /// Right-aligns the column's cells, matching Flutter's `DataColumn`
  /// convention for numeric data.
  final bool numeric;
}

/// A single row of pre-built cell widgets in an [AppDataTable].
///
/// [id] is an opaque row identifier used for selection/row-tap callbacks -
/// `design_system` never interprets it, keeping this component free of any
/// feature's domain entity (`Product`/`Order`/etc.) knowledge.
class AppDataRowData {
  const AppDataRowData({required this.id, required this.cells});

  final String id;
  final List<Widget> cells;
}

/// A responsive data table with sort/select/row-action support, per
/// docs/08_COMPONENT_LIBRARY.md §15 (`AdminDataTable`). Used across every
/// Product/Category/Order/Customer/Promotion management screen.
///
/// Accepts a [ListViewState] rather than a raw `List<AppDataRowData>` so a
/// screen structurally cannot forget to handle loading/empty/error - see
/// docs/08_COMPONENT_LIBRARY.md §18 and `state/list_view_state.dart`.
///
/// ```dart
/// AppDataTable(
///   columns: const [AppDataColumn(label: 'Name'), AppDataColumn(label: 'Stock', numeric: true)],
///   state: state.rows,
///   selectable: true,
///   selectedIds: state.selectedIds,
///   onSelectionChanged: (ids) => bloc.add(SelectionChanged(ids)),
///   onRowTap: (id) => router.go('/admin/products/$id'),
/// );
/// ```
class AppDataTable extends StatelessWidget {
  const AppDataTable({
    required this.columns,
    required this.state,
    this.selectable = false,
    this.selectedIds = const {},
    this.onSelectionChanged,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.onRowTap,
    this.emptyMessage = 'No data available',
    this.onRetry,
    super.key,
  });

  final List<AppDataColumn> columns;
  final ListViewState<AppDataRowData> state;

  final bool selectable;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>>? onSelectionChanged;

  final int? sortColumnIndex;
  final bool sortAscending;

  /// Called with the tapped column index when [AppDataColumn.sortable] is
  /// `true` for that column.
  final void Function(int columnIndex, bool ascending)? onSort;

  final ValueChanged<String>? onRowTap;

  final String emptyMessage;
  final VoidCallback? onRetry;

  void _toggleRow(String id, bool selected) {
    final updated = {...selectedIds};
    if (selected) {
      updated.add(id);
    } else {
      updated.remove(id);
    }
    onSelectionChanged?.call(updated);
  }

  void _toggleAll(List<AppDataRowData> rows, bool selectAll) {
    onSelectionChanged?.call(selectAll ? rows.map((r) => r.id).toSet() : {});
  }

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      ListViewLoading<AppDataRowData>() => _buildLoading(),
      ListViewError<AppDataRowData>(:final message) => AppErrorState(
        title: 'Something went wrong',
        message: message,
        onRetry: onRetry,
      ),
      ListViewEmpty<AppDataRowData>() => AppTableEmptyRow(
        message: emptyMessage,
      ),
      ListViewLoaded<AppDataRowData>(:final items) => _buildTable(items),
    };
  }

  Widget _buildLoading() {
    return Column(
      children: List.generate(
        5,
        (_) => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: AppShimmerPlaceholder(variant: AppShimmerVariant.listTile),
        ),
      ),
    );
  }

  Widget _buildTable(List<AppDataRowData> rows) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: sortColumnIndex,
        sortAscending: sortAscending,
        showCheckboxColumn: selectable,
        onSelectAll: selectable
            ? (value) => _toggleAll(rows, value ?? false)
            : null,
        columns: [
          for (var i = 0; i < columns.length; i++)
            DataColumn(
              label: Text(columns[i].label),
              numeric: columns[i].numeric,
              onSort: columns[i].sortable && onSort != null
                  ? (columnIndex, ascending) => onSort!(columnIndex, ascending)
                  : null,
            ),
        ],
        rows: [
          for (final row in rows)
            DataRow(
              selected: selectedIds.contains(row.id),
              onSelectChanged: selectable
                  ? (selected) => _toggleRow(row.id, selected ?? false)
                  : (onRowTap != null ? (_) => onRowTap!(row.id) : null),
              cells: [for (final cell in row.cells) DataCell(cell)],
            ),
        ],
      ),
    );
  }
}

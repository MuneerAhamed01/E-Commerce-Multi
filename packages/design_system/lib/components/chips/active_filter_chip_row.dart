import 'package:flutter/material.dart';

import '../../tokens/app_spacing.dart';

/// A single currently-applied filter, as displayed by
/// [AppActiveFilterChipRow].
class AppActiveFilter {
  const AppActiveFilter({required this.id, required this.label});

  /// Opaque identifier the caller uses to know which filter was removed -
  /// design_system doesn't interpret it.
  final String id;

  final String label;
}

/// A horizontally-scrolling row of currently-applied filters with
/// individual and bulk removal, per docs/08_COMPONENT_LIBRARY.md §6
/// (`ActiveFilterChipRow`). Used on Product Listing and Search Results.
///
/// Renders nothing (`SizedBox.shrink`) when [filters] is empty, so callers
/// can place it unconditionally above a result list.
///
/// ```dart
/// AppActiveFilterChipRow(
///   filters: activeFilters,
///   onRemove: (id) => bloc.add(FilterRemoved(id)),
///   onClearAll: () => bloc.add(const FiltersCleared()),
/// );
/// ```
class AppActiveFilterChipRow extends StatelessWidget {
  const AppActiveFilterChipRow({
    required this.filters,
    required this.onRemove,
    this.onClearAll,
    super.key,
  });

  final List<AppActiveFilter> filters;
  final ValueChanged<String> onRemove;
  final VoidCallback? onClearAll;

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in filters)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: InputChip(
                label: Text(filter.label),
                onDeleted: () => onRemove(filter.id),
              ),
            ),
          if (onClearAll != null)
            TextButton(onPressed: onClearAll, child: const Text('Clear all')),
        ],
      ),
    );
  }
}

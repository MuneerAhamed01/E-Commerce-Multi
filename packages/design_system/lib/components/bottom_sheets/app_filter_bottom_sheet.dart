import 'package:flutter/material.dart';

import '../../tokens/app_spacing.dart';
import '../buttons/app_button.dart';
import '../chips/app_filter_chip.dart';

/// A single selectable option within an [AppFilterGroup].
class AppFilterOption {
  const AppFilterOption({required this.id, required this.label});

  final String id;
  final String label;
}

/// A named group of related [AppFilterOption]s (e.g. "Brand", "Size"),
/// rendered as a labeled section of chips within [AppFilterBottomSheet].
class AppFilterGroup {
  const AppFilterGroup({required this.title, required this.options});

  final String title;
  final List<AppFilterOption> options;
}

/// A multi-facet filter selection sheet, per
/// docs/08_COMPONENT_LIBRARY.md §4 (`FilterBottomSheet`). Used on Product
/// Listing and Search Results.
///
/// Selection is staged locally until [onApply] is invoked, so navigating
/// away without tapping "Apply" discards in-progress changes - the caller
/// only ever sees a committed filter set.
///
/// ```dart
/// AppFilterBottomSheet.show(
///   context,
///   groups: availableFilterGroups,
///   activeFilterIds: activeFilters,
///   onApply: (ids) => bloc.add(FiltersApplied(ids)),
///   onClear: () => bloc.add(const FiltersCleared()),
/// );
/// ```
class AppFilterBottomSheet extends StatefulWidget {
  const AppFilterBottomSheet({
    required this.groups,
    required this.activeFilterIds,
    required this.onApply,
    this.onClear,
    this.isApplying = false,
    super.key,
  });

  final List<AppFilterGroup> groups;
  final Set<String> activeFilterIds;
  final ValueChanged<Set<String>> onApply;
  final VoidCallback? onClear;
  final bool isApplying;

  static Future<void> show(
    BuildContext context, {
    required List<AppFilterGroup> groups,
    required Set<String> activeFilterIds,
    required ValueChanged<Set<String>> onApply,
    VoidCallback? onClear,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AppFilterBottomSheet(
        groups: groups,
        activeFilterIds: activeFilterIds,
        onApply: onApply,
        onClear: onClear,
      ),
    );
  }

  @override
  State<AppFilterBottomSheet> createState() => _AppFilterBottomSheetState();
}

class _AppFilterBottomSheetState extends State<AppFilterBottomSheet> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = {...widget.activeFilterIds};
  }

  void _toggle(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: () {
                    setState(_selectedIds.clear);
                    widget.onClear?.call();
                  },
                  child: const Text('Clear all'),
                ),
              ],
            ),
            for (final group in widget.groups) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(group.title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final option in group.options)
                    AppFilterChip(
                      label: option.label,
                      selected: _selectedIds.contains(option.id),
                      onTap: (selected) => _toggle(option.id, selected),
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Apply',
              isFullWidth: true,
              isLoading: widget.isApplying,
              onPressed: () {
                widget.onApply(_selectedIds);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

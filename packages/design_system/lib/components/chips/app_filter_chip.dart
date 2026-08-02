import 'package:flutter/material.dart';

/// A toggleable filter facet, per docs/08_COMPONENT_LIBRARY.md §6
/// (`FilterChip`, renamed `AppFilterChip` here to disambiguate from
/// Flutter's own `FilterChip` widget - see docs/02_PROJECT_STRUCTURE.md
/// §10). Used in the filter bottom sheet and active-filter rows.
///
/// ```dart
/// AppFilterChip(label: 'In Stock', selected: isInStock, onTap: toggle);
/// ```
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap,
    );
  }
}

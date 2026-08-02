import 'package:flutter/material.dart';

/// A tappable recent/trending search term, per
/// docs/08_COMPONENT_LIBRARY.md §6 (`RecentSearchChip`). Used on the Search
/// entry screen.
///
/// ```dart
/// AppRecentSearchChip(
///   label: 'running shoes',
///   onTap: () => bloc.add(SearchSubmitted('running shoes')),
///   onRemove: () => bloc.add(RecentSearchRemoved('running shoes')),
/// );
/// ```
class AppRecentSearchChip extends StatelessWidget {
  const AppRecentSearchChip({
    required this.label,
    required this.onTap,
    this.onRemove,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      avatar: const Icon(Icons.history, size: 18),
      label: Text(label),
      onPressed: onTap,
      onDeleted: onRemove,
    );
  }
}

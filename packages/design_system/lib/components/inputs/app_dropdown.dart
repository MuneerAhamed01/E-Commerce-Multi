import 'package:flutter/material.dart';

/// A labeled option in an [AppDropdown].
class AppDropdownItem<T> {
  const AppDropdownItem({required this.value, required this.label});

  final T value;
  final String label;
}

/// A generic labeled dropdown/select, per docs/08_COMPONENT_LIBRARY.md §5
/// (`AppDropdown<T>`). Used across admin forms and the sort-selection UI.
///
/// ```dart
/// AppDropdown<OrderStatus>(
///   label: 'Status',
///   value: selectedStatus,
///   items: OrderStatus.values
///       .map((s) => AppDropdownItem(value: s, label: s.displayName))
///       .toList(),
///   onChanged: (status) => setState(() => selectedStatus = status),
/// );
/// ```
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    required this.items,
    required this.onChanged,
    this.value,
    this.label,
    this.enabled = true,
    super.key,
  });

  final List<AppDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final String? label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in items)
          DropdownMenuItem<T>(value: item.value, child: Text(item.label)),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}

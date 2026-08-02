import 'package:flutter/material.dart';

import '../../tokens/app_spacing.dart';

/// A single choice offered by an [AppSortBottomSheet].
class AppSortOption<T> {
  const AppSortOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// A sort-option selection sheet, per docs/08_COMPONENT_LIBRARY.md §4
/// (`SortBottomSheet`). Used on Product Listing and Search Results.
///
/// ```dart
/// AppSortBottomSheet.show<ProductSort>(
///   context,
///   options: const [
///     AppSortOption(value: ProductSort.priceLowToHigh, label: 'Price: Low to High'),
///     AppSortOption(value: ProductSort.newest, label: 'Newest'),
///   ],
///   selected: currentSort,
/// ).then((sort) { if (sort != null) bloc.add(SortChanged(sort)); });
/// ```
class AppSortBottomSheet<T> extends StatelessWidget {
  const AppSortBottomSheet({
    required this.options,
    required this.selected,
    super.key,
  });

  final List<AppSortOption<T>> options;
  final T selected;

  /// Shows the sheet modally, resolving to the tapped option's value, or
  /// `null` if dismissed without a selection.
  static Future<T?> show<T>(
    BuildContext context, {
    required List<AppSortOption<T>> options,
    required T selected,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      builder: (_) =>
          AppSortBottomSheet<T>(options: options, selected: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RadioGroup<T>(
        groupValue: selected,
        onChanged: (value) => Navigator.of(context).pop(value),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text('Sort by'),
            ),
            for (final option in options)
              RadioListTile<T>(value: option.value, title: Text(option.label)),
          ],
        ),
      ),
    );
  }
}

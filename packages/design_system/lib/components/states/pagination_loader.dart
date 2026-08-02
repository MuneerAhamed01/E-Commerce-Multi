import 'package:flutter/material.dart';

import '../../tokens/app_spacing.dart';

/// A bottom-of-list "loading more" indicator, per
/// docs/08_COMPONENT_LIBRARY.md §8 (`PaginationLoader`). Placed as the last
/// item of a `ListView`/`GridView` while a next page is being fetched.
///
/// ```dart
/// ListView.builder(
///   itemCount: items.length + (hasMore ? 1 : 0),
///   itemBuilder: (context, index) =>
///       index == items.length ? const AppPaginationLoader() : ItemTile(items[index]),
/// );
/// ```
class AppPaginationLoader extends StatelessWidget {
  const AppPaginationLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}

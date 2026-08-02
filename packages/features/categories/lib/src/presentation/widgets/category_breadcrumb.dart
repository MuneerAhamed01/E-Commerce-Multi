import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/category.dart';

/// Feature wrapper around [AppCategoryBreadcrumb] using [Category] nodes.
class CategoryBreadcrumb extends StatelessWidget {
  const CategoryBreadcrumb({
    required this.path,
    required this.onCategoryTap,
    this.includeAllRoot = false,
    this.onAllTap,
    super.key,
  });

  /// Root-first path; last segment is the current (non-tappable) page.
  final List<Category> path;

  /// Invoked with the tapped ancestor (never the last/current segment).
  final ValueChanged<Category> onCategoryTap;

  /// When true, prefixes an "All" segment that calls [onAllTap].
  final bool includeAllRoot;
  final VoidCallback? onAllTap;

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      if (includeAllRoot) 'All',
      ...path.map((c) => c.name),
    ];
    if (labels.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppCategoryBreadcrumb(
      path: labels,
      onSegmentTap: (index) {
        if (includeAllRoot) {
          if (index == 0) {
            onAllTap?.call();
            return;
          }
          final categoryIndex = index - 1;
          if (categoryIndex >= 0 && categoryIndex < path.length - 1) {
            onCategoryTap(path[categoryIndex]);
          }
          return;
        }
        if (index >= 0 && index < path.length - 1) {
          onCategoryTap(path[index]);
        }
      },
    );
  }
}

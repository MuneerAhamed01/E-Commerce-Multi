import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/app_spacing.dart';

/// A hierarchical path navigation trail, per
/// docs/08_COMPONENT_LIBRARY.md §12 (`CategoryBreadcrumb`). Used on
/// Category Detail to show/navigate the ancestor chain.
///
/// [path] is ordered root-first; tapping any non-last segment invokes
/// [onSegmentTap] with that segment's index. The last segment is rendered
/// as the current (non-tappable) page.
///
/// ```dart
/// AppCategoryBreadcrumb(
///   path: const ['Home', 'Electronics', 'Laptops'],
///   onSegmentTap: (index) => bloc.add(BreadcrumbSegmentTapped(index)),
/// );
/// ```
class AppCategoryBreadcrumb extends StatelessWidget {
  const AppCategoryBreadcrumb({
    required this.path,
    required this.onSegmentTap,
    super.key,
  });

  final List<String> path;
  final ValueChanged<int> onSegmentTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final semantic = context.semanticColors;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < path.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: semantic.disabledForeground,
                ),
              ),
            if (i == path.length - 1)
              Text(path[i], style: textTheme.labelLarge)
            else
              InkWell(
                onTap: () => onSegmentTap(i),
                child: Text(
                  path[i],
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

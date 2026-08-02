import 'package:flutter/material.dart';

import '../../tokens/app_spacing.dart';
import '../buttons/app_icon_button.dart';

/// Explicit page-number navigation for admin tables, per
/// docs/08_COMPONENT_LIBRARY.md §14 (`AppPaginationControl`). Used by
/// [AppDataTable].
///
/// [currentPage] and [totalPages] are 1-indexed for direct display.
///
/// ```dart
/// AppPaginationControl(
///   currentPage: state.page,
///   totalPages: state.totalPages,
///   onPageChange: (page) => bloc.add(PageRequested(page)),
/// );
/// ```
class AppPaginationControl extends StatelessWidget {
  const AppPaginationControl({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChange,
    super.key,
  }) : assert(currentPage >= 1, 'currentPage must be >= 1'),
       assert(totalPages >= 1, 'totalPages must be >= 1');

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Page $currentPage of $totalPages',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: AppSpacing.sm),
        AppIconButton(
          icon: Icons.chevron_left,
          tooltip: 'Previous page',
          onPressed: currentPage > 1
              ? () => onPageChange(currentPage - 1)
              : null,
        ),
        AppIconButton(
          icon: Icons.chevron_right,
          tooltip: 'Next page',
          onPressed: currentPage < totalPages
              ? () => onPageChange(currentPage + 1)
              : null,
        ),
      ],
    );
  }
}

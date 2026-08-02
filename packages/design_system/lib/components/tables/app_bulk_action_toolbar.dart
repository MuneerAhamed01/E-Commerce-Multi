import 'package:flutter/material.dart';

import '../../tokens/app_radii.dart';
import '../../tokens/app_spacing.dart';
import '../buttons/app_icon_button.dart';
import '../buttons/app_text_link_button.dart';

/// A single bulk action offered by an [AppBulkActionToolbar].
class AppBulkAction {
  const AppBulkAction({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
}

/// A contextual toolbar shown when one or more [AppDataTable] rows are
/// selected, per docs/08_COMPONENT_LIBRARY.md §15 (`BulkActionToolbar`).
///
/// ```dart
/// if (selectedIds.isNotEmpty)
///   AppBulkActionToolbar(
///     selectedCount: selectedIds.length,
///     actions: [AppBulkAction(label: 'Delete', icon: Icons.delete_outline, onPressed: onBulkDelete)],
///     onClearSelection: () => setState(selectedIds.clear),
///   );
/// ```
class AppBulkActionToolbar extends StatelessWidget {
  const AppBulkActionToolbar({
    required this.selectedCount,
    required this.actions,
    this.onClearSelection,
    super.key,
  });

  final int selectedCount;
  final List<AppBulkAction> actions;
  final VoidCallback? onClearSelection;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: AppRadii.borderRadiusSm,
      ),
      child: Row(
        children: [
          Text(
            '$selectedCount selected',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          for (final action in actions)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: action.icon != null
                  ? AppIconButton(
                      icon: action.icon!,
                      tooltip: action.label,
                      onPressed: action.onPressed,
                    )
                  : AppTextLinkButton(
                      label: action.label,
                      onPressed: action.onPressed,
                    ),
            ),
          const Spacer(),
          if (onClearSelection != null)
            AppIconButton(
              icon: Icons.close,
              tooltip: 'Clear selection',
              onPressed: onClearSelection,
            ),
        ],
      ),
    );
  }
}

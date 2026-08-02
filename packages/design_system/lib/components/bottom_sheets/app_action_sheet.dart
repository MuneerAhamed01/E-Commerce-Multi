import 'package:flutter/material.dart';

/// A single action offered by an [AppActionSheet].
class AppActionSheetAction {
  const AppActionSheetAction({
    required this.label,
    required this.onTap,
    this.icon,
    this.isDestructive = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  /// Renders the action's text/icon in the theme's error color.
  final bool isDestructive;
}

/// A generic list of contextual actions presented as a modal bottom sheet,
/// per docs/08_COMPONENT_LIBRARY.md §4 (`AppActionSheet`). Used for an
/// order line item's long-press menu and an admin table row's "more" menu.
///
/// ```dart
/// AppActionSheet.show(
///   context,
///   actions: [
///     AppActionSheetAction(label: 'Reorder', icon: Icons.replay, onTap: onReorder),
///     AppActionSheetAction(
///       label: 'Remove',
///       icon: Icons.delete_outline,
///       isDestructive: true,
///       onTap: onRemove,
///     ),
///   ],
/// );
/// ```
class AppActionSheet extends StatelessWidget {
  const AppActionSheet({required this.actions, super.key});

  final List<AppActionSheetAction> actions;

  /// Shows the sheet modally. Each action's `onTap` is invoked *after* the
  /// sheet is popped, so the caller doesn't need to pop it manually.
  static Future<void> show(
    BuildContext context, {
    required List<AppActionSheetAction> actions,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (_) => AppActionSheet(actions: actions),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final action in actions)
            ListTile(
              leading: action.icon != null
                  ? Icon(
                      action.icon,
                      color: action.isDestructive ? colorScheme.error : null,
                    )
                  : null,
              title: Text(
                action.label,
                style: action.isDestructive
                    ? TextStyle(color: colorScheme.error)
                    : null,
              ),
              onTap: () {
                Navigator.of(context).pop();
                action.onTap();
              },
            ),
        ],
      ),
    );
  }
}

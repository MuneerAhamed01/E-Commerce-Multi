import 'package:flutter/material.dart';

/// Visual treatment of an [AppFloatingActionButton]. See
/// docs/08_COMPONENT_LIBRARY.md §1.
enum AppFabVariant {
  /// Icon + [label] pill, used when there's room to be explicit about the
  /// action (e.g. "Create Product").
  extended,

  /// Icon-only circular button, used on narrower breakpoints.
  mini,
}

/// The primary screen-level action on mobile breakpoints (e.g. admin
/// "Create Product/Category/Coupon"), per docs/08_COMPONENT_LIBRARY.md §1
/// (`AppFloatingActionButton`).
///
/// ```dart
/// AppFloatingActionButton(
///   variant: AppFabVariant.extended,
///   icon: Icons.add,
///   label: 'Create Product',
///   onPressed: onCreate,
/// );
/// ```
class AppFloatingActionButton extends StatelessWidget {
  const AppFloatingActionButton({
    required this.icon,
    required this.onPressed,
    this.variant = AppFabVariant.mini,
    this.label,
    super.key,
  }) : assert(
         variant != AppFabVariant.extended || label != null,
         'label is required when variant is AppFabVariant.extended',
       );

  final IconData icon;

  /// `null` renders the button disabled.
  final VoidCallback? onPressed;

  final AppFabVariant variant;

  /// Required when [variant] is [AppFabVariant.extended].
  final String? label;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      AppFabVariant.extended => FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
      ),
      AppFabVariant.mini => FloatingActionButton(
        onPressed: onPressed,
        mini: true,
        child: Icon(icon),
      ),
    };
  }
}

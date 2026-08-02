import 'package:flutter/material.dart';

import '../../tokens/app_radii.dart';

/// Visual treatment of an [AppIconButton]. See
/// docs/08_COMPONENT_LIBRARY.md §1.
enum AppIconButtonVariant {
  /// No container, icon-colored only.
  standard,

  /// Filled container using the theme's primary color.
  filled,

  /// Outlined container.
  outline,
}

/// Icon-only tappable action, per docs/08_COMPONENT_LIBRARY.md §1
/// (`AppIconButton`). Used for app bar actions, table row actions, and cart
/// quantity controls.
///
/// A [tooltip] is required so every icon-only control has an accessible
/// label (docs/03_DEVELOPMENT_PHASES.md Phase 27.2 accessibility audit
/// depends on this being universal from day one).
///
/// ```dart
/// AppIconButton(
///   icon: Icons.favorite_border,
///   tooltip: 'Add to wishlist',
///   onPressed: () => cubit.toggle(productId),
/// );
/// ```
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.variant = AppIconButtonVariant.standard,
    this.size = 24,
    super.key,
  });

  final IconData icon;

  /// `null` renders the button disabled.
  final VoidCallback? onPressed;

  final String tooltip;

  final AppIconButtonVariant variant;

  /// Icon glyph size in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return switch (variant) {
      AppIconButtonVariant.standard => IconButton(
        icon: Icon(icon, size: size),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
      AppIconButtonVariant.filled => IconButton(
        icon: Icon(icon, size: size),
        onPressed: onPressed,
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.onSurface.withValues(
            alpha: 0.12,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.borderRadiusFull,
          ),
        ),
      ),
      AppIconButtonVariant.outline => IconButton(
        icon: Icon(icon, size: size),
        onPressed: onPressed,
        tooltip: tooltip,
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.borderRadiusFull,
          ),
        ),
      ),
    };
  }
}

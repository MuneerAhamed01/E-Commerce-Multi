import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/app_radii.dart';

/// Semantic tone of an [AppSnackbar]. See docs/08_COMPONENT_LIBRARY.md §17.
enum AppSnackbarVariant { success, info, warning, error }

/// A transient confirmation/info/error toast, per
/// docs/08_COMPONENT_LIBRARY.md §17 (`AppSnackbar`). Used for add-to-cart
/// confirmations, save confirmations, and non-blocking errors.
///
/// This is a *presenter*, not a widget in the tree - call [show] with a
/// `BuildContext` from within a `Scaffold`.
///
/// ```dart
/// AppSnackbar.show(context, message: 'Added to cart', variant: AppSnackbarVariant.success);
/// ```
abstract final class AppSnackbar {
  /// Shows a themed [SnackBar] via the nearest `ScaffoldMessenger`.
  static void show(
    BuildContext context, {
    required String message,
    AppSnackbarVariant variant = AppSnackbarVariant.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final semantic = context.semanticColors;
    final colorScheme = Theme.of(context).colorScheme;
    final (background, foreground, icon) = switch (variant) {
      AppSnackbarVariant.success => (
        semantic.success,
        semantic.onSuccess,
        Icons.check_circle_outline,
      ),
      AppSnackbarVariant.info => (
        semantic.info,
        semantic.onInfo,
        Icons.info_outline,
      ),
      AppSnackbarVariant.warning => (
        semantic.warning,
        semantic.onWarning,
        Icons.warning_amber_outlined,
      ),
      AppSnackbarVariant.error => (
        colorScheme.error,
        colorScheme.onError,
        Icons.error_outline,
      ),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: background,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.borderRadiusSm,
          ),
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(icon, color: foreground, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(message, style: TextStyle(color: foreground)),
              ),
            ],
          ),
          action: actionLabel != null && onAction != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: foreground,
                  onPressed: onAction,
                )
              : null,
        ),
      );
  }
}

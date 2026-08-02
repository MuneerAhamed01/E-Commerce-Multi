import 'package:flutter/material.dart';

import '../../tokens/app_radii.dart';
import '../../tokens/app_spacing.dart';

/// Visual treatment of an [AppButton]. See docs/08_COMPONENT_LIBRARY.md §1.
enum AppButtonVariant {
  /// Filled, high-emphasis - the default choice for a screen's main action.
  primary,

  /// Filled with the theme's secondary color - a second action of similar
  /// weight to primary but visually distinct.
  secondary,

  /// Outlined, medium-emphasis.
  outline,

  /// No container, lowest emphasis (but still a full-size tap target,
  /// unlike [AppTextLinkButton]).
  text,

  /// Filled with the theme's error color - irreversible/destructive actions.
  destructive,
}

/// Size tier of an [AppButton]. See docs/08_COMPONENT_LIBRARY.md §1.
enum AppButtonSize { sm, md, lg }

/// The platform's primary tappable-action button, covering every variant in
/// docs/08_COMPONENT_LIBRARY.md §1 (`AppButton`).
///
/// Used for every CTA/form-submit/dialog-confirm action in the app - never
/// build a bespoke button locally (docs/06_DEVELOPMENT_RULES.md Rule 9).
///
/// ```dart
/// AppButton(
///   label: 'Place Order',
///   onPressed: () => bloc.add(const PlaceOrderRequested()),
///   isLoading: state.isSubmitting,
///   isFullWidth: true,
/// );
/// ```
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    super.key,
  });

  /// The button's visible text.
  final String label;

  /// Called when tapped. A `null` value renders the button in its disabled
  /// state, regardless of [isLoading].
  final VoidCallback? onPressed;

  final AppButtonVariant variant;

  final AppButtonSize size;

  /// Optional leading icon, hidden while [isLoading] is `true`.
  final IconData? icon;

  /// When `true`, replaces [label] with an inline spinner and disables
  /// taps, without changing the button's size (avoids layout jump).
  final bool isLoading;

  /// When `true`, expands to fill the available width.
  final bool isFullWidth;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = _buttonStyle(colorScheme);
    final content = _Content(
      label: label,
      icon: icon,
      isLoading: isLoading,
      size: size,
      spinnerColor: _spinnerColorFor(colorScheme),
    );

    final Widget button = switch (variant) {
      AppButtonVariant.outline => OutlinedButton(
        onPressed: _isEnabled ? onPressed : null,
        style: style,
        child: content,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: _isEnabled ? onPressed : null,
        style: style,
        child: content,
      ),
      AppButtonVariant.primary ||
      AppButtonVariant.secondary ||
      AppButtonVariant.destructive => ElevatedButton(
        onPressed: _isEnabled ? onPressed : null,
        style: style,
        child: content,
      ),
    };

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  Color _spinnerColorFor(ColorScheme colorScheme) {
    return switch (variant) {
      AppButtonVariant.primary => colorScheme.onPrimary,
      AppButtonVariant.secondary => colorScheme.onSecondary,
      AppButtonVariant.destructive => colorScheme.onError,
      AppButtonVariant.outline || AppButtonVariant.text => colorScheme.primary,
    };
  }

  ButtonStyle _buttonStyle(ColorScheme colorScheme) {
    const shape = RoundedRectangleBorder(borderRadius: AppRadii.borderRadiusSm);
    final resolvedPadding = EdgeInsets.symmetric(
      horizontal: switch (size) {
        AppButtonSize.sm => AppSpacing.md,
        AppButtonSize.md => AppSpacing.lg,
        AppButtonSize.lg => AppSpacing.xl,
      },
    );
    final minimumSize = Size(0, switch (size) {
      AppButtonSize.sm => 36,
      AppButtonSize.md => 44,
      AppButtonSize.lg => 52,
    });

    return switch (variant) {
      AppButtonVariant.primary => ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        minimumSize: minimumSize,
        padding: resolvedPadding,
        shape: shape,
      ),
      AppButtonVariant.secondary => ElevatedButton.styleFrom(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        minimumSize: minimumSize,
        padding: resolvedPadding,
        shape: shape,
      ),
      AppButtonVariant.destructive => ElevatedButton.styleFrom(
        backgroundColor: colorScheme.error,
        foregroundColor: colorScheme.onError,
        disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        minimumSize: minimumSize,
        padding: resolvedPadding,
        shape: shape,
      ),
      AppButtonVariant.outline => OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        side: BorderSide(color: colorScheme.outline),
        minimumSize: minimumSize,
        padding: resolvedPadding,
        shape: shape,
      ),
      AppButtonVariant.text => TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        minimumSize: minimumSize,
        padding: resolvedPadding,
        shape: shape,
      ),
    };
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.size,
    required this.spinnerColor,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;
  final AppButtonSize size;
  final Color spinnerColor;

  @override
  Widget build(BuildContext context) {
    final spinnerSize = switch (size) {
      AppButtonSize.sm => 14.0,
      AppButtonSize.md => 16.0,
      AppButtonSize.lg => 18.0,
    };

    if (isLoading) {
      return SizedBox(
        height: spinnerSize,
        width: spinnerSize,
        child: CircularProgressIndicator(strokeWidth: 2, color: spinnerColor),
      );
    }

    if (icon == null) {
      return Text(label);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: spinnerSize + 2),
        const SizedBox(width: AppSpacing.sm),
        Text(label),
      ],
    );
  }
}

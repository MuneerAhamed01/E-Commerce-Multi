import 'package:flutter/material.dart';

/// A low-emphasis inline action rendered as underlined-on-hover link text,
/// per docs/08_COMPONENT_LIBRARY.md §1 (`AppTextLinkButton`). Used for
/// secondary actions like "Forgot password?", "View all", "Clear filters" -
/// where a full [AppButton] would be visually too heavy.
///
/// ```dart
/// AppTextLinkButton(label: 'Forgot password?', onPressed: onForgotPassword);
/// ```
class AppTextLinkButton extends StatelessWidget {
  const AppTextLinkButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;

  /// `null` renders the link disabled.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(decoration: TextDecoration.underline),
      ),
    );
  }
}

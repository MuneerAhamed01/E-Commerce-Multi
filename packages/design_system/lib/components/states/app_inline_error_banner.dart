import 'package:flutter/material.dart';

import '../../tokens/app_radii.dart';
import '../../tokens/app_spacing.dart';

/// A compact inline error, non-full-screen, per
/// docs/08_COMPONENT_LIBRARY.md §10 (`AppInlineErrorBanner`). Used for
/// form-level failures and partial-section failures (e.g. one Home section
/// fails while others load).
///
/// ```dart
/// if (state.formError != null)
///   AppInlineErrorBanner(message: state.formError!, onDismiss: () => bloc.add(const FormErrorDismissed()));
/// ```
class AppInlineErrorBanner extends StatelessWidget {
  const AppInlineErrorBanner({
    required this.message,
    this.onDismiss,
    super.key,
  });

  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: AppRadii.borderRadiusSm,
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 18,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(
                Icons.close,
                size: 18,
                color: colorScheme.onErrorContainer,
              ),
              tooltip: 'Dismiss',
              onPressed: onDismiss,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

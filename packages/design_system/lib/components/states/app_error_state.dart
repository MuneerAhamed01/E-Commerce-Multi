import 'package:flutter/material.dart';

import '../../tokens/app_spacing.dart';
import '../buttons/app_button.dart';

/// A generic error block with a retry action, per
/// docs/08_COMPONENT_LIBRARY.md §10 (`AppErrorState`). Every async screen's
/// error case uses this (docs/06_DEVELOPMENT_RULES.md Rule 19).
///
/// [message] is expected to already be a user-facing string resolved from a
/// typed `Failure` via a `FailureMessageMapper` at the feature boundary -
/// this widget has no knowledge of `core`'s `Failure` hierarchy, keeping
/// `design_system` presentation-only.
///
/// ```dart
/// AppErrorState(
///   title: 'Something went wrong',
///   message: failureMessageMapper.map(state.failure),
///   onRetry: () => bloc.add(const OrdersRequested()),
/// );
/// ```
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.title,
    required this.message,
    this.onRetry,
    super.key,
  });

  final String title;
  final String message;

  /// `null` hides the retry button (e.g. a genuinely unrecoverable error).
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Retry',
                variant: AppButtonVariant.outline,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

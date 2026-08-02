import 'package:flutter/material.dart';

import '../../tokens/app_spacing.dart';

/// Size/context tier of an [AppLoadingIndicator]. See
/// docs/08_COMPONENT_LIBRARY.md §8.
enum AppLoadingIndicatorSize {
  /// Inline within a button or small control.
  small,

  /// A standalone loading block within a section of a screen.
  medium,

  /// A full-screen/full-surface overlay, dimming content behind it.
  overlay,
}

/// A generic spinner, per docs/08_COMPONENT_LIBRARY.md §8
/// (`AppLoadingIndicator`). Used for full-screen loads and (via
/// `AppButton.isLoading`) inline button loading.
///
/// ```dart
/// AppLoadingIndicator(size: AppLoadingIndicatorSize.medium, message: 'Loading orders…');
/// ```
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    this.size = AppLoadingIndicatorSize.medium,
    this.message,
    super.key,
  });

  final AppLoadingIndicatorSize size;

  /// Optional caption shown under the spinner. Ignored for
  /// [AppLoadingIndicatorSize.small].
  final String? message;

  @override
  Widget build(BuildContext context) {
    final diameter = switch (size) {
      AppLoadingIndicatorSize.small => 16.0,
      AppLoadingIndicatorSize.medium => 32.0,
      AppLoadingIndicatorSize.overlay => 40.0,
    };

    final spinner = SizedBox(
      width: diameter,
      height: diameter,
      child: const CircularProgressIndicator(strokeWidth: 3),
    );

    if (size == AppLoadingIndicatorSize.small) {
      return spinner;
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        spinner,
        if (message != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(message!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    );

    if (size == AppLoadingIndicatorSize.overlay) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.2),
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}

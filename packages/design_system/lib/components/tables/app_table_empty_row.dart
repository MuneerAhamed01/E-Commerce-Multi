import 'package:flutter/material.dart';

import '../../tokens/app_spacing.dart';
import '../buttons/app_button.dart';

/// A zero-rows placeholder rendered within a table shell, per
/// docs/08_COMPONENT_LIBRARY.md §15 (`TableEmptyRow`). Distinct from
/// `AppEmptyState` (which is a full-page block) - this is sized to sit
/// inside an [AppDataTable]'s body.
///
/// ```dart
/// AppTableEmptyRow(message: 'No products match these filters', ctaLabel: 'Clear filters', onCtaPressed: onClear);
/// ```
class AppTableEmptyRow extends StatelessWidget {
  const AppTableEmptyRow({
    required this.message,
    this.ctaLabel,
    this.onCtaPressed,
    super.key,
  });

  final String message;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
            if (ctaLabel != null) ...[
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: ctaLabel!,
                variant: AppButtonVariant.text,
                onPressed: onCtaPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

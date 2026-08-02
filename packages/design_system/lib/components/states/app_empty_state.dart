import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/app_spacing.dart';
import '../buttons/app_button.dart';

/// A generic empty-state block (illustration + message + optional CTA), per
/// docs/08_COMPONENT_LIBRARY.md §9 (`AppEmptyState`). Every list/detail
/// screen's empty case uses this (docs/06_DEVELOPMENT_RULES.md Rule 18) -
/// copy is sourced by the caller from `TenantConfig.copyOverrides`
/// (docs/06_DEVELOPMENT_RULES.md Rule 37); this widget itself never reads
/// `TenantConfig`.
///
/// [illustration] defaults to a neutral icon when omitted, so a screen can
/// adopt this widget before a bespoke illustration asset exists.
///
/// ```dart
/// AppEmptyState(
///   title: tenantConfig.copy.resolve('wishlist.empty.title', 'Your wishlist is empty'),
///   message: tenantConfig.copy.resolve('wishlist.empty.message', 'Save items you love for later.'),
///   ctaLabel: 'Browse products',
///   onCtaPressed: () => router.go('/products'),
/// );
/// ```
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    this.message,
    this.illustration,
    this.ctaLabel,
    this.onCtaPressed,
    super.key,
  }) : assert(
         (ctaLabel == null) == (onCtaPressed == null),
         'ctaLabel and onCtaPressed must be provided together',
       );

  final String title;
  final String? message;

  /// Defaults to a neutral inbox icon when omitted.
  final Widget? illustration;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final semantic = context.semanticColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            illustration ??
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: semantic.disabledForeground,
                ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: semantic.disabledForeground,
                ),
              ),
            ],
            if (ctaLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(label: ctaLabel!, onPressed: onCtaPressed),
            ],
          ],
        ),
      ),
    );
  }
}

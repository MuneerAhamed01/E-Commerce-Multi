import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/app_spacing.dart';
import '../buttons/app_icon_button.dart';

/// Semantic tone of an [AppBanner]. See docs/08_COMPONENT_LIBRARY.md §17.
enum AppBannerVariant { info, warning, error }

/// A persistent in-page announcement, per docs/08_COMPONENT_LIBRARY.md §17
/// (`AppBanner`). Used for maintenance notices and tenant announcements
/// (`NetworkOfflineBanner`/`AppNetworkOfflineBanner` covers the
/// connectivity-specific case as its own component).
///
/// ```dart
/// AppBanner(
///   variant: AppBannerVariant.warning,
///   message: tenantConfig.copy.resolve('banner.maintenance', 'Scheduled maintenance tonight.'),
///   onDismiss: () => cubit.dismissBanner(),
/// );
/// ```
class AppBanner extends StatelessWidget {
  const AppBanner({
    required this.message,
    this.variant = AppBannerVariant.info,
    this.onDismiss,
    super.key,
  });

  final String message;
  final AppBannerVariant variant;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final colorScheme = Theme.of(context).colorScheme;
    final (background, foreground, icon) = switch (variant) {
      AppBannerVariant.info => (
        semantic.infoContainer,
        semantic.onInfoContainer,
        Icons.info_outline,
      ),
      AppBannerVariant.warning => (
        semantic.warningContainer,
        semantic.onWarningContainer,
        Icons.warning_amber_outlined,
      ),
      AppBannerVariant.error => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
        Icons.error_outline,
      ),
    };

    return Material(
      color: background,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: foreground),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: foreground),
              ),
            ),
            if (onDismiss != null)
              AppIconButton(
                icon: Icons.close,
                tooltip: 'Dismiss',
                onPressed: onDismiss,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}

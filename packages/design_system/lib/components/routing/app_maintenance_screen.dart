import 'package:flutter/material.dart';

import '../../tokens/app_spacing.dart';
import '../buttons/app_button.dart';
import '../feedback/app_banner.dart';

/// Full-screen maintenance mode surface (docs/09_ROUTING_PLAN.md §8).
///
/// Shown when `AppConfig.storefrontMaintenanceMode` /
/// `adminMaintenanceMode` is active. The optional [onRetry] CTA lets the
/// user re-check (e.g. hot-restart / re-navigate) once the flag clears.
class AppMaintenanceScreen extends StatelessWidget {
  const AppMaintenanceScreen({
    this.message =
        'We are performing scheduled maintenance. Please try again shortly.',
    this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.construction_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Under maintenance',
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppBanner(message: message, variant: AppBannerVariant.warning),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.lg),
                AppButton(label: 'Try again', onPressed: onRetry),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

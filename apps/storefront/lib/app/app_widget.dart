import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Root widget of the Storefront app.
///
/// Phase 4 wires [AppTheme] from [TenantConfig]. When developer mode is
/// available the home screen is the shared [DesignSystemGallery] so the
/// Phase 4 completion criterion (light/dark + two tenants) is reachable
/// without a dedicated route yet. Phase 5 replaces this with
/// `MaterialApp.router`.
class AppWidget extends StatelessWidget {
  const AppWidget({
    required this.appConfig,
    required this.tenantConfig,
    super.key,
  });

  /// Resolved once at bootstrap by the active `main_<flavor>.dart` entry
  /// point - see docs/11_ENVIRONMENT_CONFIGURATION.md §10.
  final AppConfig appConfig;

  /// Loaded once at bootstrap from `config/tenants/<tenantId>_tenant.json`.
  final TenantConfig tenantConfig;

  @override
  Widget build(BuildContext context) {
    if (appConfig.isDeveloperModeAvailable) {
      return const DesignSystemGallery();
    }

    return MaterialApp(
      title: tenantConfig.displayName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(tenantConfig),
      darkTheme: AppTheme.dark(tenantConfig),
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppTopBar(title: tenantConfig.displayName),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tenantConfig.displayName,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Storefront',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Environment: ${appConfig.environment.name}'),
                    Text('Tenant: ${tenantConfig.tenantId}'),
                    Text('Data source: ${appConfig.dataSourceMode.name}'),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Phase 4: Design System wired.\n'
                      'Real routing arrives in Phase 5.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (tenantConfig.featureFlags.isEnabled(
                      FeatureFlag.wishlist,
                    )) ...[
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: 'Wishlist (feature-flagged)',
                        variant: AppButtonVariant.outline,
                        onPressed: () {},
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

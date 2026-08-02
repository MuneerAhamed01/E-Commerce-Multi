import 'dart:async';
import 'dart:convert';

import 'package:admin_dashboard/admin_dashboard.dart';
import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'app/app_widget.dart';

/// Shared startup sequence for the Admin app, invoked by every
/// `main_<flavor>.dart` entry point so those files stay trivial (see
/// docs/02_PROJECT_STRUCTURE.md §3). Implements the configuration-loading
/// sequence from docs/11_ENVIRONMENT_CONFIGURATION.md §10:
///
/// 1. Load [AppConfig] from compiled flavor constants + `--dart-define`s.
/// 2. Load [TenantConfig] from the bundled `config/tenants/*.json` asset.
/// 3. Initialize [AppLogger] with `AppConfig.logLevel`.
/// 4. Initialize the DI container (`get_it` + `injectable`).
/// 5. Register each feature's injection module - none yet (Phase 3 scope
///    has no features; starts in Phase 21+).
/// 6. Build `AppTheme` from `TenantConfig.branding` - deferred to Phase 4
///    (Design System); `AppWidget` reads `TenantConfig` directly for now.
/// 7. `runApp(...)`, wrapped in a `runZonedGuarded` safety net per
///    docs/05_ARCHITECTURE_GUIDELINES.md §14.
Future<void> bootstrap({
  required Environment environment,
  required String tenantId,
  bool developerModeForcedOff = false,
}) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final appConfig = AppConfig.forEnvironment(
        environment,
        developerModeForcedOff: developerModeForcedOff,
      );
      final tenantConfig = await _loadTenantConfig(tenantId);

      configureCoreInjection();
      final logger = getIt<AppLogger>()..setMinLevel(appConfig.logLevel);
      getIt.registerSingleton<AppConfig>(appConfig);
      getIt.registerSingleton<TenantConfig>(tenantConfig);
      getIt.registerSingleton<FeatureFlagService>(
        FeatureFlagService(flags: tenantConfig.featureFlags),
      );
      // Mock infrastructure + reference ping stack (Phase 6). Requires
      // AppConfig to already be registered.
      configureMockInjection();
      // Auth feature (Phase 7) — shared use cases; admin login uses requireAdmin.
      await configureAuthenticationInjection();
      // Admin dashboard KPIs (Phase 8).
      configureAdminDashboardInjection();

      FlutterError.onError = (details) {
        logger.error(
          'Uncaught Flutter framework error',
          feature: 'admin',
          error: details.exception,
          stackTrace: details.stack,
        );
      };

      logger.info(
        'Admin bootstrap complete. '
        'environment=${appConfig.environment.name} '
        'tenant=${tenantConfig.tenantId} '
        'dataSourceMode=${appConfig.dataSourceMode.name} '
        'developerMode=${appConfig.isDeveloperModeAvailable}',
        feature: 'admin',
      );

      runApp(AppWidget(appConfig: appConfig, tenantConfig: tenantConfig));
    },
    (error, stackTrace) {
      // Fallback for errors thrown outside Flutter's own error zone (e.g.
      // in an async gap during bootstrap itself, before the logger might
      // even be registered) - see docs/05_ARCHITECTURE_GUIDELINES.md §14.
      if (getIt.isRegistered<AppLogger>()) {
        getIt<AppLogger>().error(
          'Uncaught zone error',
          feature: 'admin',
          error: error,
          stackTrace: stackTrace,
        );
      }
    },
  );
}

Future<TenantConfig> _loadTenantConfig(String tenantId) async {
  // `assets/tenants/` is a symlink to the canonical `config/tenants/` at
  // the repo root - see the `flutter: assets:` comment in pubspec.yaml and
  // docs/11_ENVIRONMENT_CONFIGURATION.md §6.
  final raw = await rootBundle.loadString(
    'assets/tenants/${tenantId}_tenant.json',
  );
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return TenantConfig.fromJson(json);
}

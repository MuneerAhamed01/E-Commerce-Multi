import 'package:core/core.dart';

import 'bootstrap.dart';

/// Entry point for the `prod` flavor. Run with:
///   fvm flutter run -t lib/main_prod.dart --release --dart-define-from-file=../../config/env/prod.env -d chrome
Future<void> main() {
  return bootstrap(
    environment: Environment.prod,
    tenantId: const String.fromEnvironment(
      'DEFAULT_TENANT_ID',
      defaultValue: 'default',
    ),
    // Hardcoded source-level literal - not sourced from an environment
    // variable - so a misconfigured ENABLE_DEVELOPER_MODE can never ship
    // developer tooling in a production build. See
    // docs/11_ENVIRONMENT_CONFIGURATION.md §8.
    developerModeForcedOff: true,
  );
}

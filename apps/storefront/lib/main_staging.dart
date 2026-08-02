import 'package:core/core.dart';

import 'bootstrap.dart';

/// Entry point for the `staging` flavor. Run with:
///   fvm flutter run -t lib/main_staging.dart --dart-define-from-file=../../config/env/staging.env
Future<void> main() {
  return bootstrap(
    environment: Environment.staging,
    tenantId: const String.fromEnvironment(
      'DEFAULT_TENANT_ID',
      defaultValue: 'default',
    ),
  );
}

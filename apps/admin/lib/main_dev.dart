import 'package:core/core.dart';

import 'bootstrap.dart';

/// Entry point for the `dev` flavor. Run with:
///   fvm flutter run -t lib/main_dev.dart --dart-define-from-file=../../config/env/dev.env
Future<void> main() {
  return bootstrap(
    environment: Environment.dev,
    tenantId: const String.fromEnvironment(
      'DEFAULT_TENANT_ID',
      defaultValue: 'default',
    ),
  );
}

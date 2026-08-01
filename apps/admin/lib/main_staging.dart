import 'bootstrap.dart';

/// Entry point for the `staging` flavor. Run with:
///   fvm flutter run -t lib/main_staging.dart -d chrome
Future<void> main() => bootstrap(flavor: 'staging');

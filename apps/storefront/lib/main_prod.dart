import 'bootstrap.dart';

/// Entry point for the `prod` flavor. Run with:
///   fvm flutter run -t lib/main_prod.dart --release
Future<void> main() => bootstrap(flavor: 'prod');

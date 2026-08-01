import 'package:injectable/injectable.dart';

/// Abstraction over device connectivity, consulted by repository
/// implementations before attempting a network-backed operation so a
/// [NetworkFailure] can be returned immediately instead of waiting for a
/// timeout. See docs/05_ARCHITECTURE_GUIDELINES.md §13.
abstract class NetworkInfo {
  /// Whether the device currently has a usable network connection.
  Future<bool> get isConnected;
}

/// Default [NetworkInfo] implementation for this plan's mock-data-only
/// scope, where `AppConfig.dataSourceMode` never leaves `mock` and no
/// operation actually depends on real device connectivity. Always reports
/// connected.
///
/// A real implementation (e.g. backed by `connectivity_plus`) is swapped
/// in via this same DI registration once a genuinely network-backed data
/// source exists - see docs/05_ARCHITECTURE_GUIDELINES.md §18.
@LazySingleton(as: NetworkInfo)
final class AlwaysOnlineNetworkInfo implements NetworkInfo {
  const AlwaysOnlineNetworkInfo();

  @override
  Future<bool> get isConnected async => true;
}

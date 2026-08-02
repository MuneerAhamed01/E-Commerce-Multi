/// Well-known mock call-type keys used with [MockDeveloperControls]
/// failure injection and [MockNetworkSimulator.run].
///
/// Feature packages should add their own constants locally (e.g.
/// `'products.list'`) rather than bloating this file with every endpoint.
abstract final class MockCallTypes {
  /// Reference ping demo used by the Developer Panel (Phase 6).
  static const String ping = 'ping';
}

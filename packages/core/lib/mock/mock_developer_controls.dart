/// In-memory developer-panel toggles for mock latency overrides and
/// failure injection.
///
/// Registered as a lazy singleton via [configureMockInjection] so every
/// mock data source (and the Developer Panel UI) share one control surface.
/// See docs/10_DATA_FLOW.md §2 and docs/11_ENVIRONMENT_CONFIGURATION.md §8.
final class MockDeveloperControls {
  MockDeveloperControls();

  /// When non-null, overrides [AppConfig.mockLatencyMin] for
  /// [MockNetworkSimulator].
  Duration? latencyMinOverride;

  /// When non-null, overrides [AppConfig.mockLatencyMax] for
  /// [MockNetworkSimulator].
  Duration? latencyMaxOverride;

  /// When `true`, [MockNetworkSimulator] skips artificial delay entirely
  /// (useful for widget tests and snappy local QA).
  bool latencyDisabled = false;

  final Set<String> _forcedFailures = <String>{};

  final List<void Function()> _resetListeners = <void Function()>[];

  /// Call types currently forced to fail (e.g. `'ping'`, `'products.list'`).
  Set<String> get forcedFailures => Set<String>.unmodifiable(_forcedFailures);

  /// Whether [callType] should throw a simulated server error.
  bool shouldFail(String callType) => _forcedFailures.contains(callType);

  /// Forces the next (and subsequent) mock calls of [callType] to fail
  /// until cleared.
  void forceFailure(String callType) => _forcedFailures.add(callType);

  /// Clears failure injection for a single [callType].
  void clearFailure(String callType) => _forcedFailures.remove(callType);

  /// Clears every forced-failure toggle.
  void clearAllFailures() => _forcedFailures.clear();

  /// Toggles failure injection for [callType]. Returns the new enabled
  /// state.
  bool toggleFailure(String callType) {
    if (_forcedFailures.contains(callType)) {
      _forcedFailures.remove(callType);
      return false;
    }
    _forcedFailures.add(callType);
    return true;
  }

  /// Applies or clears a latency-range override used by
  /// [MockNetworkSimulator]. Pass `null` for either bound to clear that
  /// override (and fall back to [AppConfig] defaults).
  void setLatencyOverride({Duration? min, Duration? max}) {
    latencyMinOverride = min;
    latencyMaxOverride = max;
  }

  /// Clears latency overrides and re-enables simulated delay.
  void clearLatencyOverride() {
    latencyMinOverride = null;
    latencyMaxOverride = null;
    latencyDisabled = false;
  }

  /// Registers a listener invoked by [resetMockData]. Feature mock stores
  /// register here so the Developer Panel's "Reset mock data" button can
  /// restore every in-memory fixture set in one tap.
  void registerResetListener(void Function() listener) {
    _resetListeners.add(listener);
  }

  /// Unregisters a previously registered reset listener.
  void unregisterResetListener(void Function() listener) {
    _resetListeners.remove(listener);
  }

  /// Restores every registered mock store to its seed fixtures and clears
  /// failure-injection toggles (latency overrides are left as-is so QA can
  /// keep a preferred delay while resetting catalog state).
  void resetMockData() {
    clearAllFailures();
    for (final listener in List<void Function()>.of(_resetListeners)) {
      listener();
    }
  }
}

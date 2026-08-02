import 'dart:async';
import 'dart:math';

import '../config/app_config.dart';
import '../error/exception.dart';
import 'mock_developer_controls.dart';

/// Shared latency + failure simulation used by every feature's mock data
/// source (docs/10_DATA_FLOW.md §2 — `MockNetworkSimulator`).
///
/// Feature mock data sources call [run] (or [simulate]) around each
/// asynchronous operation instead of reimplementing `Future.delayed` /
/// failure checks locally.
final class MockNetworkSimulator {
  MockNetworkSimulator({
    required AppConfig appConfig,
    required MockDeveloperControls controls,
    Random? random,
  }) : _appConfig = appConfig, // ignore: prefer_initializing_formals
       _controls = controls, // ignore: prefer_initializing_formals
       _random = random ?? Random();

  final AppConfig _appConfig;
  final MockDeveloperControls _controls;
  final Random _random;

  /// Effective lower latency bound (developer override or [AppConfig]).
  Duration get effectiveLatencyMin =>
      _controls.latencyMinOverride ?? _appConfig.mockLatencyMin;

  /// Effective upper latency bound (developer override or [AppConfig]).
  Duration get effectiveLatencyMax =>
      _controls.latencyMaxOverride ?? _appConfig.mockLatencyMax;

  /// Waits a random duration in `[effectiveLatencyMin, effectiveLatencyMax]`
  /// unless latency is disabled via [MockDeveloperControls.latencyDisabled].
  Future<void> simulateLatency() async {
    if (_controls.latencyDisabled) {
      return;
    }

    final minMs = effectiveLatencyMin.inMilliseconds;
    final maxMs = effectiveLatencyMax.inMilliseconds;
    if (maxMs <= 0 || maxMs < minMs) {
      return;
    }

    final delayMs = minMs == maxMs
        ? minMs
        : minMs + _random.nextInt(maxMs - minMs + 1);
    if (delayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: delayMs));
    }
  }

  /// Throws [ServerException] when [MockDeveloperControls] has forced a
  /// failure for [callType].
  void maybeThrowFailure(String callType) {
    if (_controls.shouldFail(callType)) {
      throw ServerException('Simulated mock failure for "$callType"', 500);
    }
  }

  /// Runs [action] after latency simulation and optional failure injection.
  ///
  /// This is the canonical entry point for mock data sources:
  /// ```dart
  /// Future<List<ProductModel>> fetchProducts() =>
  ///   simulator.run('products.list', () async => _store.products);
  /// ```
  Future<T> run<T>(String callType, FutureOr<T> Function() action) async {
    await simulateLatency();
    maybeThrowFailure(callType);
    return action();
  }

  /// Same as [run] but with no return value (mutations / fire-and-forget).
  Future<void> simulate(String callType) => run<void>(callType, () {});
}

import 'dart:math';

import 'package:core/core.dart';
import 'package:test/test.dart';

AppConfig _devConfig({
  Duration latencyMin = const Duration(milliseconds: 10),
  Duration latencyMax = const Duration(milliseconds: 20),
}) {
  return AppConfig(
    environment: Environment.dev,
    dataSourceMode: DataSourceMode.mock,
    logLevel: LogLevel.debug,
    mockLatencyMin: latencyMin,
    mockLatencyMax: latencyMax,
    isDeveloperModeAvailable: true,
  );
}

void main() {
  group('MockNetworkSimulator', () {
    test('applies latency in the configured range', () async {
      final controls = MockDeveloperControls();
      final simulator = MockNetworkSimulator(
        appConfig: _devConfig(),
        controls: controls,
        random: Random(1),
      );

      final stopwatch = Stopwatch()..start();
      final value = await simulator.run('demo', () async => 42);
      stopwatch.stop();

      expect(value, 42);
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(10));
    });

    test('skips latency when disabled via developer controls', () async {
      final controls = MockDeveloperControls()..latencyDisabled = true;
      final simulator = MockNetworkSimulator(
        appConfig: _devConfig(
          latencyMin: const Duration(seconds: 2),
          latencyMax: const Duration(seconds: 3),
        ),
        controls: controls,
      );

      final stopwatch = Stopwatch()..start();
      await simulator.run('demo', () async => null);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });

    test('throws ServerException when failure is forced', () async {
      final controls = MockDeveloperControls()
        ..latencyDisabled = true
        ..forceFailure(MockCallTypes.ping);
      final simulator = MockNetworkSimulator(
        appConfig: _devConfig(),
        controls: controls,
      );

      expect(
        () => simulator.run(MockCallTypes.ping, () async => 'ok'),
        throwsA(isA<ServerException>()),
      );
    });

    test('honors latency override from developer controls', () async {
      final controls = MockDeveloperControls()
        ..setLatencyOverride(
          min: const Duration(milliseconds: 5),
          max: const Duration(milliseconds: 5),
        );
      final simulator = MockNetworkSimulator(
        appConfig: _devConfig(
          latencyMin: const Duration(seconds: 5),
          latencyMax: const Duration(seconds: 5),
        ),
        controls: controls,
        random: Random(0),
      );

      final stopwatch = Stopwatch()..start();
      await simulator.simulateLatency();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(5));
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });
  });

  group('MockDeveloperControls', () {
    test('resetMockData clears failures and notifies listeners', () {
      final controls = MockDeveloperControls()..forceFailure('x');
      var resets = 0;
      controls.registerResetListener(() => resets++);

      controls.resetMockData();

      expect(controls.forcedFailures, isEmpty);
      expect(resets, 1);
    });

    test('toggleFailure flips membership', () {
      final controls = MockDeveloperControls();
      expect(controls.toggleFailure('a'), isTrue);
      expect(controls.shouldFail('a'), isTrue);
      expect(controls.toggleFailure('a'), isFalse);
      expect(controls.shouldFail('a'), isFalse);
    });
  });
}

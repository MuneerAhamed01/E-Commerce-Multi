import 'dart:math';

import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('GetPing reference stack', () {
    late MockDeveloperControls controls;
    late MockSeedStore store;
    late GetPing getPing;

    setUp(() {
      controls = MockDeveloperControls()..latencyDisabled = true;
      store = MockSeedStore(controls: controls);
      final simulator = MockNetworkSimulator(
        appConfig: const AppConfig(
          environment: Environment.dev,
          dataSourceMode: DataSourceMode.mock,
          logLevel: LogLevel.debug,
          mockLatencyMin: Duration.zero,
          mockLatencyMax: Duration.zero,
          isDeveloperModeAvailable: true,
        ),
        controls: controls,
        random: Random(0),
      );
      final remote = MockPingRemoteDataSource(
        simulator: simulator,
        store: store,
      );
      getPing = GetPing(MockPingRepository(remote));
    });

    test('returns success with seed product count', () async {
      final result = await getPing(const NoParams());

      expect(result.isSuccess, isTrue);
      final message = result.valueOrNull!;
      expect(message.message, contains('pong'));
      expect(message.productCount, store.products.length);
    });

    test('maps forced failure to ServerFailure', () async {
      controls.forceFailure(MockCallTypes.ping);

      final result = await getPing(const NoParams());

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ServerFailure>());
    });
  });
}

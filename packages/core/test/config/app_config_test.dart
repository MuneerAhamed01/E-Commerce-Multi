import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('AppConfig.forEnvironment', () {
    test(
      'dev defaults to mock data source, debug logging, developer mode on',
      () {
        final config = AppConfig.forEnvironment(Environment.dev);

        expect(config.environment, Environment.dev);
        expect(config.dataSourceMode, DataSourceMode.mock);
        expect(config.logLevel, LogLevel.debug);
        expect(config.isDeveloperModeAvailable, isTrue);
      },
    );

    test(
      'staging defaults to mock data source, info logging, developer mode on',
      () {
        final config = AppConfig.forEnvironment(Environment.staging);

        expect(config.dataSourceMode, DataSourceMode.mock);
        expect(config.logLevel, LogLevel.info);
        expect(config.isDeveloperModeAvailable, isTrue);
      },
    );

    test(
      'prod defaults to mock data source, warning logging, developer mode off',
      () {
        final config = AppConfig.forEnvironment(Environment.prod);

        expect(config.dataSourceMode, DataSourceMode.mock);
        expect(config.logLevel, LogLevel.warning);
        expect(config.isDeveloperModeAvailable, isFalse);
      },
    );

    test(
      'developerModeForcedOff always wins, even for an environment that defaults to true',
      () {
        final config = AppConfig.forEnvironment(
          Environment.dev,
          developerModeForcedOff: true,
        );

        expect(config.isDeveloperModeAvailable, isFalse);
      },
    );

    test('mock latency defaults to 300-800ms', () {
      final config = AppConfig.forEnvironment(Environment.dev);

      expect(config.mockLatencyMin, const Duration(milliseconds: 300));
      expect(config.mockLatencyMax, const Duration(milliseconds: 800));
    });

    test('maintenance mode flags default to false', () {
      final config = AppConfig.forEnvironment(Environment.dev);

      expect(config.storefrontMaintenanceMode, isFalse);
      expect(config.adminMaintenanceMode, isFalse);
    });
  });

  group('Environment', () {
    test('isProduction is true only for prod', () {
      expect(Environment.dev.isProduction, isFalse);
      expect(Environment.staging.isProduction, isFalse);
      expect(Environment.prod.isProduction, isTrue);
    });
  });

  group('AppConfig equality', () {
    test('two configs with the same field values are equal', () {
      final a = AppConfig.forEnvironment(Environment.dev);
      final b = AppConfig.forEnvironment(Environment.dev);

      expect(a, equals(b));
    });
  });
}

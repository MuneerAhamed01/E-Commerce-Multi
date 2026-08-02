import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('ConsoleAppLogger', () {
    late ConsoleAppLogger logger;

    setUp(() {
      logger = ConsoleAppLogger();
    });

    test('debug/info/warning/error all run without throwing', () {
      expect(
        () => logger.debug('debug message', feature: 'core'),
        returnsNormally,
      );
      expect(
        () => logger.info('info message', feature: 'core'),
        returnsNormally,
      );
      expect(
        () => logger.warning('warning message', feature: 'core'),
        returnsNormally,
      );
      expect(
        () => logger.error(
          'error message',
          feature: 'core',
          error: Exception('boom'),
          stackTrace: StackTrace.current,
        ),
        returnsNormally,
      );
    });

    test('is usable without a feature name', () {
      expect(() => logger.info('no feature name'), returnsNormally);
    });

    test(
      'defaults to LogLevel.debug (everything emitted) until configured',
      () {
        expect(() => logger.debug('shown by default'), returnsNormally);
      },
    );

    test(
      'setMinLevel raises the threshold without throwing on any call site',
      () {
        logger.setMinLevel(LogLevel.warning);

        // debug/info are now below threshold and silently dropped; warning/
        // error remain at/above it. Neither path should throw.
        expect(() => logger.debug('dropped'), returnsNormally);
        expect(() => logger.info('dropped'), returnsNormally);
        expect(() => logger.warning('kept'), returnsNormally);
        expect(() => logger.error('kept'), returnsNormally);
      },
    );
  });
}

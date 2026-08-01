import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('ConsoleAppLogger', () {
    const logger = ConsoleAppLogger();

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
  });
}

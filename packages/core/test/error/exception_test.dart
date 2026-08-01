import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('AppException subtypes', () {
    test('carry an optional message surfaced via toString()', () {
      expect(const ServerException('boom', 500).message, 'boom');
      expect(const ServerException('boom', 500).statusCode, 500);
      expect(
        const ServerException('boom', 500).toString(),
        'ServerException: boom',
      );

      expect(const CacheException('boom').toString(), 'CacheException: boom');
      expect(
        const NetworkException('boom').toString(),
        'NetworkException: boom',
      );
      expect(
        const NotFoundException('boom').toString(),
        'NotFoundException: boom',
      );
      expect(
        const UnauthorizedException('boom').toString(),
        'UnauthorizedException: boom',
      );
      expect(
        const UnknownException('boom').toString(),
        'UnknownException: boom',
      );
    });

    test('toString() omits the message segment when none is provided', () {
      expect(const CacheException().toString(), 'CacheException');
    });

    test('ValidationException carries per-field error messages', () {
      const exception = ValidationException({
        'email': 'Enter a valid email address',
      });

      expect(exception.fieldErrors, {'email': 'Enter a valid email address'});
    });

    test('are all Exceptions, catchable via a generic on-clause', () {
      const AppException thrown = ServerException('boom');

      expect(thrown, isA<Exception>());
    });
  });
}

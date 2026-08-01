import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('Failure', () {
    test('subtypes carry their own fields and support value equality', () {
      expect(
        const ServerFailure(statusCode: 500),
        equals(const ServerFailure(statusCode: 500)),
      );
      expect(
        const ServerFailure(statusCode: 500),
        isNot(equals(const ServerFailure(statusCode: 404))),
      );

      expect(const CacheFailure(), equals(const CacheFailure()));
      expect(const NetworkFailure(), equals(const NetworkFailure()));
      expect(const NotFoundFailure(), equals(const NotFoundFailure()));
      expect(const UnauthorizedFailure(), equals(const UnauthorizedFailure()));
      expect(const UnknownFailure(), equals(const UnknownFailure()));
    });

    test('ValidationFailure carries per-field error messages', () {
      const failure = ValidationFailure({
        'email': 'Enter a valid email address',
      });

      expect(failure.fieldErrors, {'email': 'Enter a valid email address'});
      expect(
        failure,
        equals(
          const ValidationFailure({'email': 'Enter a valid email address'}),
        ),
      );
    });

    test('InsufficientStockFailure carries the available quantity', () {
      const failure = InsufficientStockFailure(3);

      expect(failure.availableQuantity, 3);
      expect(failure, equals(const InsufficientStockFailure(3)));
      expect(failure, isNot(equals(const InsufficientStockFailure(4))));
    });

    test('different Failure subtypes with the same message are not equal', () {
      expect(
        const CacheFailure(message: 'boom'),
        isNot(equals(const NetworkFailure(message: 'boom'))),
      );
    });
  });
}

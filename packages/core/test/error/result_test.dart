import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('Result.success reports isSuccess and folds to the value', () {
      const result = Result<Failure, int>.success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.valueOrNull, 42);
      expect(result.failureOrNull, isNull);
      expect(
        result.fold(
          onFailure: (_) => 'failure',
          onSuccess: (value) => 'success: $value',
        ),
        'success: 42',
      );
    });

    test('Result.failure reports isFailure and folds to the failure', () {
      const failure = ServerFailure(statusCode: 500);
      const result = Result<ServerFailure, int>.failure(failure);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull, failure);
      expect(
        result.fold(
          onFailure: (f) => 'failure: ${f.statusCode}',
          onSuccess: (_) => 'success',
        ),
        'failure: 500',
      );
    });

    test('map transforms a success value and leaves a failure untouched', () {
      const success = Result<Failure, int>.success(2);
      const failure = NetworkFailure();
      const failed = Result<Failure, int>.failure(failure);

      expect(success.map((value) => value * 10).valueOrNull, 20);
      expect(failed.map((value) => value * 10).failureOrNull, failure);
    });

    test('flatMap chains a Result-returning step onto a success', () {
      const success = Result<Failure, int>.success(2);

      Result<Failure, int> double_(int value) => Result.success(value * 2);

      expect(success.flatMap(double_).valueOrNull, 4);
    });

    test(
      'flatMap short-circuits on a failure without invoking the transform',
      () {
        const failure = CacheFailure();
        const failed = Result<Failure, int>.failure(failure);
        var invoked = false;

        final chained = failed.flatMap((value) {
          invoked = true;
          return Result<Failure, int>.success(value * 2);
        });

        expect(invoked, isFalse);
        expect(chained.failureOrNull, failure);
      },
    );

    test(
      'getOrElse returns the value on success and the fallback on failure',
      () {
        const success = Result<Failure, int>.success(5);
        const failed = Result<Failure, int>.failure(UnknownFailure());

        expect(success.getOrElse((_) => -1), 5);
        expect(failed.getOrElse((_) => -1), -1);
      },
    );
  });
}

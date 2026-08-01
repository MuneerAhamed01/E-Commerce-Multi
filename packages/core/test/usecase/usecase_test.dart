import 'package:core/core.dart';
import 'package:test/test.dart';

/// A throwaway use case, defined only for this test, proving [UseCase] is
/// consumable exactly as a real feature would consume it: a single
/// callable `call()` returning `Result<Failure, Type>` - see completion
/// criteria in docs/03_DEVELOPMENT_PHASES.md Phase 2.
final class _AddOne extends UseCase<int, int> {
  const _AddOne();

  @override
  Future<Result<Failure, int>> call(int params) async {
    if (params < 0) {
      return const Result.failure(
        ValidationFailure({'params': 'must be non-negative'}),
      );
    }
    return Result.success(params + 1);
  }
}

/// A throwaway stream use case proving [StreamUseCase]'s realtime-shaped
/// contract works end to end.
final class _CountUpTo extends StreamUseCase<int, int> {
  const _CountUpTo();

  @override
  Stream<Result<Failure, int>> call(int params) async* {
    for (var i = 1; i <= params; i++) {
      yield Result.success(i);
    }
  }
}

void main() {
  group('UseCase', () {
    test(
      'is invoked via the callable-class syntax and returns a Result',
      () async {
        const useCase = _AddOne();

        final result = await useCase(1);

        expect(result.valueOrNull, 2);
      },
    );

    test('propagates a typed Failure through the Result', () async {
      const useCase = _AddOne();

      final result = await useCase(-1);

      expect(result.failureOrNull, isA<ValidationFailure>());
    });

    test(
      'NoParams is usable as the Params type for parameterless use cases',
      () async {
        final useCase = _ConstantTen();

        final result = await useCase(const NoParams());

        expect(result.valueOrNull, 10);
      },
    );
  });

  group('StreamUseCase', () {
    test(
      'emits a Result per item as the underlying stream progresses',
      () async {
        const useCase = _CountUpTo();

        final values = await useCase(
          3,
        ).map((result) => result.valueOrNull).toList();

        expect(values, [1, 2, 3]);
      },
    );
  });
}

final class _ConstantTen extends UseCase<int, NoParams> {
  @override
  Future<Result<Failure, int>> call(NoParams params) async =>
      const Result.success(10);
}

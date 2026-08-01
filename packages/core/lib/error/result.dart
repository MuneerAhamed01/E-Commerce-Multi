import 'failure.dart';

/// An Either-style outcome of an operation that can fail: either a
/// [Success] carrying a value of type [S], or a [ResultFailure] carrying a
/// typed [Failure] subtype [F].
///
/// Every repository method, and every [UseCase.call], returns this instead
/// of a raw value with thrown exceptions or a nullable value with a silent
/// `null` for the error case. See docs/05_ARCHITECTURE_GUIDELINES.md §8.
sealed class Result<F extends Failure, S> {
  const Result();

  /// Creates a successful [Result] carrying [value].
  const factory Result.success(S value) = Success<F, S>;

  /// Creates a failed [Result] carrying [failure].
  const factory Result.failure(F failure) = ResultFailure<F, S>;

  /// `true` if this is a [Success].
  bool get isSuccess => this is Success<F, S>;

  /// `true` if this is a [ResultFailure].
  bool get isFailure => !isSuccess;

  /// Reduces this [Result] to a single value of type [R] by handling both
  /// branches exhaustively - the primary way to consume a [Result].
  R fold<R>({
    required R Function(F failure) onFailure,
    required R Function(S value) onSuccess,
  }) {
    final self = this;
    return switch (self) {
      Success<F, S>(value: final value) => onSuccess(value),
      ResultFailure<F, S>(failure: final failure) => onFailure(failure),
    };
  }

  /// Transforms the success value, leaving a failure untouched.
  Result<F, R> map<R>(R Function(S value) transform) {
    return fold(
      onFailure: Result<F, R>.failure,
      onSuccess: (value) => Result<F, R>.success(transform(value)),
    );
  }

  /// Chains another [Result]-returning step onto a successful value,
  /// leaving a failure untouched (monadic bind - useful for composing
  /// multiple repository calls inside a use case).
  Result<F, R> flatMap<R>(Result<F, R> Function(S value) transform) {
    return fold(onFailure: Result<F, R>.failure, onSuccess: transform);
  }

  /// The success value, or `null` if this is a failure.
  S? get valueOrNull =>
      fold(onFailure: (_) => null, onSuccess: (value) => value);

  /// The failure, or `null` if this is a success.
  F? get failureOrNull =>
      fold(onFailure: (failure) => failure, onSuccess: (_) => null);

  /// The success value, or the result of [orElse] applied to the failure.
  S getOrElse(S Function(F failure) orElse) {
    return fold(onFailure: orElse, onSuccess: (value) => value);
  }
}

/// The successful branch of a [Result], carrying the resulting [value].
final class Success<F extends Failure, S> extends Result<F, S> {
  const Success(this.value);

  /// The value produced by the successful operation.
  final S value;
}

/// The failed branch of a [Result], carrying the typed [failure].
///
/// Named `ResultFailure` (not `Failure`) to avoid colliding with the
/// `Failure` type hierarchy itself - a `ResultFailure<ServerFailure, User>`
/// carries a `ServerFailure`.
final class ResultFailure<F extends Failure, S> extends Result<F, S> {
  const ResultFailure(this.failure);

  /// The typed failure describing what went wrong.
  final F failure;
}

/// Base type for exceptions thrown only within a feature's `data/` layer
/// (data sources and repository implementations).
///
/// Nothing above the repository-implementation boundary ever catches a raw
/// [Exception] - the repository implementation is the only place that
/// catches one of these and translates it into a typed [Failure]. See
/// docs/05_ARCHITECTURE_GUIDELINES.md §6 and §13.
sealed class AppException implements Exception {
  const AppException([this.message]);

  /// Optional technical detail carried through to the mapped [Failure].
  final String? message;

  @override
  String toString() => '$runtimeType${message != null ? ': $message' : ''}';
}

/// Thrown by a data source when the backing source (mock or, later,
/// Firebase/REST) returns an unexpected error. Maps to [ServerFailure].
final class ServerException extends AppException {
  const ServerException([super.message, this.statusCode]);

  /// HTTP-style status code, when known.
  final int? statusCode;
}

/// Thrown by a data source on a local cache/storage read or write failure.
/// Maps to [CacheFailure].
final class CacheException extends AppException {
  const CacheException([super.message]);
}

/// Thrown by a data source when there is no usable network connection, or
/// a network call times out. Maps to [NetworkFailure].
final class NetworkException extends AppException {
  const NetworkException([super.message]);
}

/// Thrown by a data source when the requested resource does not exist.
/// Maps to [NotFoundFailure].
final class NotFoundException extends AppException {
  const NotFoundException([super.message]);
}

/// Thrown by a data source when the current session is not authenticated
/// or authorized for the requested operation. Maps to [UnauthorizedFailure].
final class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message]);
}

/// Thrown by a data source when input fails validation before it ever
/// reaches a backing source. Maps to [ValidationFailure].
final class ValidationException extends AppException {
  const ValidationException(this.fieldErrors, [super.message]);

  /// Field name -> error message for that field.
  final Map<String, String> fieldErrors;
}

/// Thrown by a data source for a genuinely unanticipated error. Maps to
/// [UnknownFailure].
final class UnknownException extends AppException {
  const UnknownException([super.message]);
}

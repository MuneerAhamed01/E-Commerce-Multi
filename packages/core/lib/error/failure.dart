import 'package:equatable/equatable.dart';

/// Base type for every typed, user-facing error condition in the platform.
///
/// Every repository method that can fail returns a [Result] carrying a
/// concrete [Failure] subtype - never a raw [Exception] and never a bare
/// [String] surfaced directly to the UI. See
/// docs/05_ARCHITECTURE_GUIDELINES.md §5 and §13.
///
/// [message] is an optional technical detail for logs/debugging only - it
/// is never shown to the user directly. User-facing copy is derived by a
/// `FailureMessageMapper` (added when the first feature needs it) so error
/// copy stays centralized and tenant-copy-overridable.
sealed class Failure extends Equatable {
  const Failure({this.message});

  /// Optional technical message for logs/debugging. Never PII.
  final String? message;

  @override
  List<Object?> get props => [message];
}

/// The backing data source (mock or, later, Firebase/REST) returned an
/// unexpected error - e.g. a simulated 5xx from a mock data source, or a
/// Firestore/HTTP failure once that integration exists.
final class ServerFailure extends Failure {
  const ServerFailure({super.message, this.statusCode});

  /// HTTP-style status code, when known. Null for mock-data-simulated
  /// failures that don't carry one.
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// A local cache/storage read or write failed (e.g. corrupted local data,
/// storage quota, or a missing cached value that was required).
final class CacheFailure extends Failure {
  const CacheFailure({super.message});
}

/// The device has no usable network connection, or a network call timed
/// out. See [NetworkInfo] for the connectivity check this is paired with.
final class NetworkFailure extends Failure {
  const NetworkFailure({super.message});
}

/// User-supplied input failed validation. [fieldErrors] maps a form field
/// name to a user-facing error message, letting a form show per-field
/// errors instead of one generic message.
final class ValidationFailure extends Failure {
  const ValidationFailure(this.fieldErrors, {super.message});

  /// Field name -> error message for that field.
  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [message, fieldErrors];
}

/// The requested resource does not exist (e.g. a product id, order id, or
/// tenant slug that no data source recognizes).
final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message});
}

/// The current user/session is not authenticated, or is authenticated but
/// not authorized to perform the requested operation (e.g. an admin-only
/// action attempted by a customer session).
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message});
}

/// A cart/checkout operation could not be completed because fewer units
/// are available than requested. Lets Cart/Checkout UI show the exact
/// number still in stock instead of a generic error.
final class InsufficientStockFailure extends Failure {
  const InsufficientStockFailure(this.availableQuantity, {super.message});

  /// The quantity actually available, so the UI can offer to adjust down
  /// to this amount instead of just failing outright.
  final int availableQuantity;

  @override
  List<Object?> get props => [message, availableQuantity];
}

/// A catch-all for errors that don't fit a more specific [Failure] type.
/// Every data-layer try/catch must still translate into a typed [Failure]
/// (see docs/05_ARCHITECTURE_GUIDELINES.md §13) - this exists for genuinely
/// unanticipated cases, not as a default shortcut.
final class UnknownFailure extends Failure {
  const UnknownFailure({super.message});
}

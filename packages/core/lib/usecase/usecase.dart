import '../error/failure.dart';
import '../error/result.dart';

/// Base contract for a single, one-shot business operation.
///
/// Exactly one public [call] method per implementation (the callable-class
/// pattern - invoked as `useCase(params)`), named as a verb (`PlaceOrder`,
/// not `OrderManager`), doing exactly one thing. A [UseCase] is the *only*
/// thing a Bloc/Cubit is allowed to depend on from its own feature's
/// domain layer - Blocs never call a repository directly. See
/// docs/05_ARCHITECTURE_GUIDELINES.md §9.
abstract class UseCase<Type, Params> {
  const UseCase();

  /// Executes this use case with [params], returning a [Result] carrying
  /// either the [Type] produced or a typed [Failure].
  Future<Result<Failure, Type>> call(Params params);
}

/// Base contract for a use case whose result is naturally a stream rather
/// than a one-shot value - e.g. order status or notification feeds that
/// will eventually be backed by Firestore's `snapshots()`. Using [Stream]
/// from day one, even against mock data, means switching the underlying
/// repository to a real realtime source later requires no consumer-side
/// (Bloc) changes. See docs/05_ARCHITECTURE_GUIDELINES.md §18.4.
abstract class StreamUseCase<Type, Params> {
  const StreamUseCase();

  /// Executes this use case with [params], returning a [Stream] of
  /// [Result]s as the underlying data changes over time.
  Stream<Result<Failure, Type>> call(Params params);
}

/// Marker type for a [UseCase]/[StreamUseCase] that takes no parameters,
/// shared across every feature so each doesn't invent its own `NoParams`
/// class. Use as `UseCase<Type, NoParams>`.
final class NoParams {
  const NoParams();
}

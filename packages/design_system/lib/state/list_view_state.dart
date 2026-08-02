import 'package:equatable/equatable.dart';

/// The state of any list-rendering surface (`AppDataTable`, and the future
/// feature-owned `ProductGrid`/`ReviewList`), so a screen structurally
/// cannot forget to handle loading/empty/error - see
/// docs/08_COMPONENT_LIBRARY.md §18: "every list-rendering component ...
/// accepts and renders all three of: loading, empty, and error ... enforced
/// structurally by having these components accept a sealed
/// `ListViewState<T>` rather than a raw `List<T>`".
///
/// This type carries no business meaning (it doesn't know what a "product"
/// or "order" is) - it is a pure presentation-layer state shape, which is
/// why it lives in `design_system` rather than `core` or a feature package.
sealed class ListViewState<T> extends Equatable {
  const ListViewState();
}

/// The list's data is being fetched for the first time (or refreshed).
final class ListViewLoading<T> extends ListViewState<T> {
  const ListViewLoading();

  @override
  List<Object?> get props => [];
}

/// Data was fetched successfully and contains at least one item.
///
/// [isLoadingMore] reflects an in-flight pagination request appended to
/// already-loaded [items] (see `AppPaginationLoader`); [hasMore] indicates
/// whether another page is available to request.
final class ListViewLoaded<T> extends ListViewState<T> {
  const ListViewLoaded(
    this.items, {
    this.isLoadingMore = false,
    this.hasMore = false,
  });

  final List<T> items;
  final bool isLoadingMore;
  final bool hasMore;

  @override
  List<Object?> get props => [items, isLoadingMore, hasMore];
}

/// Data was fetched successfully but contains zero items.
final class ListViewEmpty<T> extends ListViewState<T> {
  const ListViewEmpty();

  @override
  List<Object?> get props => [];
}

/// Fetching the list failed. [message] is a user-facing string already
/// resolved by the caller (e.g. via a feature's `FailureMessageMapper`) -
/// this type deliberately doesn't know about `core`'s `Failure` hierarchy,
/// keeping `design_system` presentation-only.
final class ListViewError<T> extends ListViewState<T> {
  const ListViewError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

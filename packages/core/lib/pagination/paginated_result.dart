import 'package:equatable/equatable.dart';

/// Shared pagination envelope returned by every list-returning repository
/// method, whether the items come from mock data or, later, Firestore's
/// `startAfter` cursor pattern - so pagination UI (an infinite-scroll list,
/// an admin data table's "next page" control) is identical regardless of
/// the backing data source. See docs/05_ARCHITECTURE_GUIDELINES.md §8.
final class PaginatedResult<T> extends Equatable {
  const PaginatedResult({
    required this.items,
    this.nextPageCursor,
    this.totalCount,
  });

  /// An empty page with no further pages - useful for empty-state tests
  /// and as a safe default.
  const PaginatedResult.empty()
    : items = const [],
      nextPageCursor = null,
      totalCount = 0;

  /// The items in this page, in server/mock order.
  final List<T> items;

  /// Opaque cursor/token to request the next page, or `null` if this is
  /// the last page. Deliberately opaque (not an offset/int) so a mock
  /// implementation's cursor scheme and a future Firestore
  /// `DocumentSnapshot`-based cursor are interchangeable without changing
  /// this contract.
  final String? nextPageCursor;

  /// Total item count across all pages, when the data source can report
  /// it cheaply. `null` when unknown (e.g. some realtime-backed sources
  /// cannot report a total without a full scan) - UI must treat `null` as
  /// "unknown", not zero.
  final int? totalCount;

  /// Whether a further page can be requested via [nextPageCursor].
  bool get hasNextPage => nextPageCursor != null;

  /// Whether this page has no items at all (distinct from "no *further*
  /// pages" - a first page can be empty and have [hasNextPage] false).
  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [items, nextPageCursor, totalCount];
}

import 'package:equatable/equatable.dart';

/// Cursor-based page request for catalog lists.
final class ProductPageRequest extends Equatable {
  const ProductPageRequest({this.cursor, this.pageSize = defaultPageSize});

  static const int defaultPageSize = 20;

  /// Opaque next-page cursor from a prior [PaginatedResult], or `null`
  /// for the first page.
  final String? cursor;
  final int pageSize;

  @override
  List<Object?> get props => [cursor, pageSize];
}

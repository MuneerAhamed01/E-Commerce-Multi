import 'package:equatable/equatable.dart';

import 'search_filter.dart';
import 'sort_option.dart';

/// Full search request payload (text + filter + sort).
///
/// Pagination cursor/page size travel separately via
/// [products.ProductPageRequest] on the use case.
final class SearchQuery extends Equatable {
  const SearchQuery({
    this.text = '',
    this.filter = SearchFilter.empty,
    this.sort = SortOption.relevance,
  });

  final String text;
  final SearchFilter filter;
  final SortOption sort;

  String get normalizedText => text.trim();

  bool get hasText => normalizedText.isNotEmpty;

  SearchQuery copyWith({String? text, SearchFilter? filter, SortOption? sort}) {
    return SearchQuery(
      text: text ?? this.text,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
    );
  }

  @override
  List<Object?> get props => [text, filter, sort];
}

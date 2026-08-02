import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:products/products.dart';

import '../entities/search_filter.dart';
import '../entities/sort_option.dart';
import '../repositories/search_repository.dart';

final class SearchProducts
    extends UseCase<PaginatedResult<Product>, SearchProductsParams> {
  const SearchProducts(this._repository);

  final SearchRepository _repository;

  @override
  Future<Result<Failure, PaginatedResult<Product>>> call(
    SearchProductsParams params,
  ) {
    return _repository.searchProducts(
      query: params.query,
      filter: params.filter,
      sort: params.sort,
      page: params.page,
    );
  }
}

final class SearchProductsParams extends Equatable {
  const SearchProductsParams({
    required this.query,
    required this.page,
    this.filter = SearchFilter.empty,
    this.sort = SortOption.relevance,
  });

  final String query;
  final SearchFilter filter;
  final SortOption sort;
  final ProductPageRequest page;

  @override
  List<Object?> get props => [query, filter, sort, page];
}

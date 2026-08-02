import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/product.dart';
import '../entities/product_filter.dart';
import '../entities/product_page_request.dart';
import '../repositories/product_repository.dart';

final class GetProducts
    extends UseCase<PaginatedResult<Product>, GetProductsParams> {
  const GetProducts(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<Failure, PaginatedResult<Product>>> call(
    GetProductsParams params,
  ) {
    return _repository.getProducts(page: params.page, filter: params.filter);
  }
}

final class GetProductsParams extends Equatable {
  const GetProductsParams({required this.page, this.filter});

  final ProductPageRequest page;
  final ProductFilter? filter;

  @override
  List<Object?> get props => [page, filter];
}

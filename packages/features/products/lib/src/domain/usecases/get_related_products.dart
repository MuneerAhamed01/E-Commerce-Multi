import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/product.dart';
import '../entities/product_page_request.dart';
import '../repositories/product_repository.dart';

final class GetRelatedProducts
    extends UseCase<PaginatedResult<Product>, GetRelatedProductsParams> {
  const GetRelatedProducts(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<Failure, PaginatedResult<Product>>> call(
    GetRelatedProductsParams params,
  ) {
    return _repository.getRelatedProducts(
      productId: params.productId,
      page: params.page,
    );
  }
}

final class GetRelatedProductsParams extends Equatable {
  const GetRelatedProductsParams({
    required this.productId,
    this.page = const ProductPageRequest(pageSize: 8),
  });

  final String productId;
  final ProductPageRequest page;

  @override
  List<Object?> get props => [productId, page];
}

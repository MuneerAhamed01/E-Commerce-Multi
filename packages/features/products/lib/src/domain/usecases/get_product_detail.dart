import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/product.dart';
import '../repositories/product_repository.dart';

final class GetProductDetail extends UseCase<Product, GetProductDetailParams> {
  const GetProductDetail(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<Failure, Product>> call(GetProductDetailParams params) {
    return _repository.getProductDetail(params.productId);
  }
}

final class GetProductDetailParams extends Equatable {
  const GetProductDetailParams(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

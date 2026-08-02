import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/product_page_request.dart';
import '../entities/review.dart';
import '../repositories/product_repository.dart';

final class GetProductReviews
    extends UseCase<PaginatedResult<Review>, GetProductReviewsParams> {
  const GetProductReviews(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<Failure, PaginatedResult<Review>>> call(
    GetProductReviewsParams params,
  ) {
    return _repository.getProductReviews(
      productId: params.productId,
      page: params.page,
    );
  }
}

final class GetProductReviewsParams extends Equatable {
  const GetProductReviewsParams({
    required this.productId,
    this.page = const ProductPageRequest(),
  });

  final String productId;
  final ProductPageRequest page;

  @override
  List<Object?> get props => [productId, page];
}

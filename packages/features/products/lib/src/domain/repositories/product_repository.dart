import 'package:core/core.dart';

import '../entities/product.dart';
import '../entities/product_filter.dart';
import '../entities/product_page_request.dart';
import '../entities/review.dart';

/// Catalog repository contract (docs/10_DATA_FLOW.md §3).
abstract interface class ProductRepository {
  Future<Result<Failure, PaginatedResult<Product>>> getProducts({
    required ProductPageRequest page,
    ProductFilter? filter,
  });

  Future<Result<Failure, Product>> getProductDetail(String productId);

  Future<Result<Failure, PaginatedResult<Product>>> getRelatedProducts({
    required String productId,
    required ProductPageRequest page,
  });

  Future<Result<Failure, PaginatedResult<Review>>> getProductReviews({
    required String productId,
    required ProductPageRequest page,
  });

  Future<Result<Failure, Review>> submitReview({
    required String productId,
    required String userId,
    required String userDisplayName,
    required int rating,
    required String title,
    required String body,
  });
}

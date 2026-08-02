import 'package:core/core.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/entities/product_page_request.dart';
import '../../domain/entities/review.dart';

/// Remote contract for catalog reads/writes (mock today, Firebase later).
abstract interface class ProductsRemoteDataSource {
  Future<PaginatedResult<Product>> fetchProducts({
    required ProductPageRequest page,
    ProductFilter? filter,
  });

  Future<Product> fetchProductDetail(String productId);

  Future<PaginatedResult<Product>> fetchRelatedProducts({
    required String productId,
    required ProductPageRequest page,
  });

  Future<PaginatedResult<Review>> fetchProductReviews({
    required String productId,
    required ProductPageRequest page,
  });

  Future<Review> submitReview({
    required String productId,
    required String userId,
    required String userDisplayName,
    required int rating,
    required String title,
    required String body,
  });
}

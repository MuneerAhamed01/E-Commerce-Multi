import 'package:core/core.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/entities/product_page_request.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/products_remote_data_source.dart';

/// Maps data-layer exceptions → [Failure] (docs/10_DATA_FLOW.md §1).
final class MockProductRepositoryImpl implements ProductRepository {
  MockProductRepositoryImpl({required this.remote});

  final ProductsRemoteDataSource remote;

  @override
  Future<Result<Failure, PaginatedResult<Product>>> getProducts({
    required ProductPageRequest page,
    ProductFilter? filter,
  }) {
    return _guard(() => remote.fetchProducts(page: page, filter: filter));
  }

  @override
  Future<Result<Failure, Product>> getProductDetail(String productId) {
    return _guard(() => remote.fetchProductDetail(productId));
  }

  @override
  Future<Result<Failure, PaginatedResult<Product>>> getRelatedProducts({
    required String productId,
    required ProductPageRequest page,
  }) {
    return _guard(
      () => remote.fetchRelatedProducts(productId: productId, page: page),
    );
  }

  @override
  Future<Result<Failure, PaginatedResult<Review>>> getProductReviews({
    required String productId,
    required ProductPageRequest page,
  }) {
    return _guard(
      () => remote.fetchProductReviews(productId: productId, page: page),
    );
  }

  @override
  Future<Result<Failure, Review>> submitReview({
    required String productId,
    required String userId,
    required String userDisplayName,
    required int rating,
    required String title,
    required String body,
  }) {
    return _guard(
      () => remote.submitReview(
        productId: productId,
        userId: userId,
        userDisplayName: userDisplayName,
        rating: rating,
        title: title,
        body: body,
      ),
    );
  }

  Future<Result<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Result.failure(UnauthorizedFailure(message: e.message));
    } on ValidationException catch (e) {
      return Result.failure(
        ValidationFailure(e.fieldErrors, message: e.message),
      );
    } on AppException catch (e) {
      return Result.failure(UnknownFailure(message: e.message));
    } on Object catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}

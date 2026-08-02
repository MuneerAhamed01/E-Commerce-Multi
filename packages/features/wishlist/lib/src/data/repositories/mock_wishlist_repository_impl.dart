import 'package:core/core.dart';

import '../../domain/entities/wishlist_item.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_remote_data_source.dart';

/// Maps data-layer exceptions → [Failure].
final class MockWishlistRepositoryImpl implements WishlistRepository {
  MockWishlistRepositoryImpl({required this.remote});

  final WishlistRemoteDataSource remote;

  @override
  Future<Result<Failure, List<WishlistItem>>> getWishlist(String userId) {
    return _guard(() => remote.fetchWishlist(userId));
  }

  @override
  Future<Result<Failure, WishlistItem>> addToWishlist({
    required String userId,
    required String productId,
    String? variantId,
  }) {
    return _guard(
      () => remote.addItem(
        userId: userId,
        productId: productId,
        variantId: variantId,
      ),
    );
  }

  @override
  Future<Result<Failure, void>> removeFromWishlist({
    required String userId,
    required String productId,
  }) {
    return _guard(
      () => remote.removeItem(userId: userId, productId: productId),
    );
  }

  @override
  Future<Result<Failure, bool>> isInWishlist({
    required String userId,
    required String productId,
  }) {
    return _guard(() => remote.contains(userId: userId, productId: productId));
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

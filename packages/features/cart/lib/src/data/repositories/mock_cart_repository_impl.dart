import 'package:core/core.dart';

import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';

/// Maps data-layer exceptions → [Failure].
final class MockCartRepositoryImpl implements CartRepository {
  MockCartRepositoryImpl({required this.remote});

  final CartRemoteDataSource remote;

  @override
  Future<Result<Failure, Cart>> getCart(String ownerId) {
    return _guard(() => remote.fetchCart(ownerId));
  }

  @override
  Future<Result<Failure, Cart>> addItem({
    required String ownerId,
    required String productId,
    required String variantId,
    required int quantity,
  }) {
    return _guard(
      () => remote.addItem(
        ownerId: ownerId,
        productId: productId,
        variantId: variantId,
        quantity: quantity,
      ),
    );
  }

  @override
  Future<Result<Failure, Cart>> updateQuantity({
    required String ownerId,
    required String productId,
    required String variantId,
    required int quantity,
  }) {
    return _guard(
      () => remote.updateQuantity(
        ownerId: ownerId,
        productId: productId,
        variantId: variantId,
        quantity: quantity,
      ),
    );
  }

  @override
  Future<Result<Failure, Cart>> removeItem({
    required String ownerId,
    required String productId,
    required String variantId,
  }) {
    return _guard(
      () => remote.removeItem(
        ownerId: ownerId,
        productId: productId,
        variantId: variantId,
      ),
    );
  }

  @override
  Future<Result<Failure, Cart>> clearCart(String ownerId) {
    return _guard(() => remote.clearCart(ownerId));
  }

  @override
  Future<Result<Failure, Cart>> applyPromoCode({
    required String ownerId,
    required String code,
  }) {
    return _guard(() => remote.applyPromoCode(ownerId: ownerId, code: code));
  }

  @override
  Future<Result<Failure, Cart>> removePromoCode(String ownerId) {
    return _guard(() => remote.removePromoCode(ownerId));
  }

  @override
  Future<Result<Failure, Cart>> mergeGuestCart({
    required String guestOwnerId,
    required String userOwnerId,
  }) {
    return _guard(
      () => remote.mergeGuestCart(
        guestOwnerId: guestOwnerId,
        userOwnerId: userOwnerId,
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
      final qty = e.fieldErrors['quantity'];
      if (qty != null && qty.startsWith('Only ')) {
        final digits = qty.replaceAll(RegExp(r'[^0-9]'), '');
        final available = int.tryParse(digits) ?? 0;
        return Result.failure(
          InsufficientStockFailure(available, message: e.message),
        );
      }
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

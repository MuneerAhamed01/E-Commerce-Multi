import 'package:core/core.dart';

import '../../domain/entities/checkout_payment_method.dart';
import '../../domain/entities/saved_address.dart';
import '../../domain/entities/shipping_method.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../datasources/checkout_remote_data_source.dart';

/// Maps data-layer exceptions → [Failure].
final class MockCheckoutRepositoryImpl implements CheckoutRepository {
  MockCheckoutRepositoryImpl({required this.remote});

  final CheckoutRemoteDataSource remote;

  @override
  Future<Result<Failure, List<SavedAddress>>> getSavedAddresses(String userId) {
    return _guard(() => remote.fetchSavedAddresses(userId));
  }

  @override
  Future<Result<Failure, SavedAddress>> saveAddress({
    required String userId,
    required Address address,
    bool makeDefault = false,
  }) {
    return _guard(
      () => remote.saveAddress(
        userId: userId,
        address: address,
        makeDefault: makeDefault,
      ),
    );
  }

  @override
  Future<Result<Failure, List<ShippingMethod>>> getShippingMethods() {
    return _guard(remote.fetchShippingMethods);
  }

  @override
  Future<Result<Failure, Money>> calculateShippingCost({
    required String methodId,
    required String postalCode,
  }) {
    return _guard(
      () => remote.calculateShippingCost(
        methodId: methodId,
        postalCode: postalCode,
      ),
    );
  }

  @override
  Future<Result<Failure, List<CheckoutPaymentMethod>>> getPaymentMethods(
    String userId,
  ) {
    return _guard(() => remote.fetchPaymentMethods(userId));
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
    } on ValidationException catch (e) {
      return Result.failure(
        ValidationFailure(e.fieldErrors, message: e.message),
      );
    } on UnauthorizedException catch (e) {
      return Result.failure(UnauthorizedFailure(message: e.message));
    } on AppException catch (e) {
      return Result.failure(UnknownFailure(message: e.message));
    } on Object catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}

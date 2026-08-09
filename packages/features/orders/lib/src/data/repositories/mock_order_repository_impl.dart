import 'package:core/core.dart';

import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

/// Maps data-layer exceptions → [Failure].
final class MockOrderRepositoryImpl implements OrderRepository {
  MockOrderRepositoryImpl({required this.remote});

  final OrderRemoteDataSource remote;

  @override
  Future<Result<Failure, Order>> createOrder(CreateOrderRequest request) {
    return _guard(() => remote.createOrder(request));
  }

  @override
  Future<Result<Failure, Order>> getOrder(String orderId) {
    return _guard(() => remote.fetchOrder(orderId));
  }

  @override
  Future<Result<Failure, List<Order>>> getOrders(String customerId) {
    return _guard(() => remote.fetchOrders(customerId));
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

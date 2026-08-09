import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

/// Remote contract for orders (mock-only in Phase 15.1).
abstract class OrderRemoteDataSource {
  Future<Order> createOrder(CreateOrderRequest request);

  Future<Order> fetchOrder(String orderId);

  Future<List<Order>> fetchOrders(String customerId);
}

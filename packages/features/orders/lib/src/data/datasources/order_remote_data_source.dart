import '../../domain/entities/order.dart';
import '../../domain/entities/order_tracking_event.dart';
import '../../domain/repositories/order_repository.dart';

/// Remote contract for orders (mock-only in Phase 15).
abstract class OrderRemoteDataSource {
  Future<Order> createOrder(CreateOrderRequest request);

  Future<Order> fetchOrder(String orderId);

  Future<List<Order>> fetchOrders(String customerId);

  Future<List<OrderTrackingEvent>> fetchTrackingEvents(String orderId);

  Future<Order> cancelOrder({
    required String orderId,
    required String customerId,
    required String reason,
  });

  Future<Order> requestReturn({
    required String orderId,
    required String customerId,
    required String reason,
  });
}

import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_tracking_event.dart';

/// Builds a synthetic chronological tracking timeline from an order's status.
abstract final class OrderTrackingBuilder {
  static List<OrderTrackingEvent> build(Order order) {
    final base = order.createdAt.toUtc();
    final events = <OrderTrackingEvent>[];

    void add({
      required OrderStatus status,
      required String title,
      required Duration offset,
      String? description,
    }) {
      events.add(
        OrderTrackingEvent(
          id: '${order.id}_${status.name}_${events.length}',
          status: status,
          title: title,
          description: description,
          occurredAt: base.add(offset),
        ),
      );
    }

    add(
      status: OrderStatus.placed,
      title: 'Order placed',
      offset: Duration.zero,
      description: 'We received your order ${order.orderNumber}.',
    );

    switch (order.status) {
      case OrderStatus.placed:
        break;
      case OrderStatus.processing:
        add(
          status: OrderStatus.processing,
          title: 'Payment confirmed',
          offset: const Duration(hours: 2),
          description: 'Your order is being prepared.',
        );
      case OrderStatus.shipped:
        add(
          status: OrderStatus.processing,
          title: 'Payment confirmed',
          offset: const Duration(hours: 2),
        );
        add(
          status: OrderStatus.shipped,
          title: 'Shipped',
          offset: const Duration(days: 1),
          description: 'Your package is on the way.',
        );
      case OrderStatus.delivered:
        add(
          status: OrderStatus.processing,
          title: 'Payment confirmed',
          offset: const Duration(hours: 2),
        );
        add(
          status: OrderStatus.shipped,
          title: 'Shipped',
          offset: const Duration(days: 1),
        );
        add(
          status: OrderStatus.delivered,
          title: 'Delivered',
          offset: const Duration(days: 4),
          description: 'Package delivered to the shipping address.',
        );
      case OrderStatus.cancelled:
        add(
          status: OrderStatus.cancelled,
          title: 'Order cancelled',
          offset: const Duration(hours: 3),
          description: 'This order was cancelled.',
        );
      case OrderStatus.returnRequested:
        add(
          status: OrderStatus.processing,
          title: 'Payment confirmed',
          offset: const Duration(hours: 2),
        );
        add(
          status: OrderStatus.shipped,
          title: 'Shipped',
          offset: const Duration(days: 1),
        );
        add(
          status: OrderStatus.delivered,
          title: 'Delivered',
          offset: const Duration(days: 4),
        );
        add(
          status: OrderStatus.returnRequested,
          title: 'Return requested',
          offset: const Duration(days: 6),
          description: 'We received your return request.',
        );
      case OrderStatus.returned:
        add(
          status: OrderStatus.processing,
          title: 'Payment confirmed',
          offset: const Duration(hours: 2),
        );
        add(
          status: OrderStatus.shipped,
          title: 'Shipped',
          offset: const Duration(days: 1),
        );
        add(
          status: OrderStatus.delivered,
          title: 'Delivered',
          offset: const Duration(days: 4),
        );
        add(
          status: OrderStatus.returnRequested,
          title: 'Return requested',
          offset: const Duration(days: 6),
        );
        add(
          status: OrderStatus.returned,
          title: 'Returned',
          offset: const Duration(days: 10),
          description: 'Return completed.',
        );
    }

    return List<OrderTrackingEvent>.unmodifiable(events);
  }
}

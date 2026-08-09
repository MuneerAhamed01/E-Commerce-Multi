import 'package:core/core.dart';

import '../../domain/entities/order.dart';
import '../../domain/entities/order_line_item.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/repositories/order_repository.dart';

/// Maps [SeedOrder] fixtures ↔ domain [Order].
abstract final class SeedOrderMapper {
  static Order toDomain(SeedOrder seed) {
    return Order(
      id: seed.id,
      orderNumber: seed.orderNumber,
      customerId: seed.customerId,
      status: OrderStatus.fromSeed(seed.status),
      createdAt:
          DateTime.tryParse(seed.createdAtIso)?.toUtc() ?? DateTime.utc(2026),
      items: seed.items
          .map(
            (item) => OrderLineItem(
              productId: item.productId,
              productName: item.productName,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
            ),
          )
          .toList(growable: false),
      shippingAddress: seed.shippingAddress,
      subtotal: seed.subtotal,
      shipping: seed.shipping,
      tax: seed.tax,
      total: seed.total,
    );
  }

  static SeedOrder toSeed(Order order) {
    return SeedOrder(
      id: order.id,
      orderNumber: order.orderNumber,
      customerId: order.customerId,
      status: order.status.toSeed(),
      createdAtIso: order.createdAt.toUtc().toIso8601String(),
      items: order.items
          .map(
            (item) => SeedOrderItem(
              productId: item.productId,
              productName: item.productName,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
            ),
          )
          .toList(growable: false),
      shippingAddress: order.shippingAddress,
      subtotal: order.subtotal,
      shipping: order.shipping,
      tax: order.tax,
      total: order.total,
    );
  }

  static Order fromCreateRequest({
    required CreateOrderRequest request,
    required String id,
    required String orderNumber,
    required DateTime createdAt,
  }) {
    return Order(
      id: id,
      orderNumber: orderNumber,
      customerId: request.customerId,
      status: OrderStatus.placed,
      createdAt: createdAt,
      items: List<OrderLineItem>.unmodifiable(request.items),
      shippingAddress: request.shippingAddress,
      subtotal: request.subtotal,
      shipping: request.shipping,
      tax: request.tax,
      total: request.total,
      paymentMethodLabel: request.paymentMethodLabel,
      shippingMethodLabel: request.shippingMethodLabel,
    );
  }
}

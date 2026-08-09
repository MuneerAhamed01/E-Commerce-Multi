import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/order.dart';
import '../entities/order_line_item.dart';

/// Customer order persistence contract (Phase 15.1).
abstract class OrderRepository {
  Future<Result<Failure, Order>> createOrder(CreateOrderRequest request);

  Future<Result<Failure, Order>> getOrder(String orderId);

  Future<Result<Failure, List<Order>>> getOrders(String customerId);
}

/// Input for placing a new order from checkout.
final class CreateOrderRequest extends Equatable {
  const CreateOrderRequest({
    required this.customerId,
    required this.items,
    required this.shippingAddress,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    this.paymentMethodLabel,
    this.shippingMethodLabel,
  });

  final String customerId;
  final List<OrderLineItem> items;
  final Address shippingAddress;
  final Money subtotal;
  final Money shipping;
  final Money tax;
  final Money total;
  final String? paymentMethodLabel;
  final String? shippingMethodLabel;

  @override
  List<Object?> get props => [
    customerId,
    items,
    shippingAddress,
    subtotal,
    shipping,
    tax,
    total,
    paymentMethodLabel,
    shippingMethodLabel,
  ];
}

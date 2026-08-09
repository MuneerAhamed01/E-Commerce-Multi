import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import 'order_line_item.dart';
import 'order_status.dart';

/// A placed customer order (Phase 15.1 domain — pulled forward for checkout).
final class Order extends Equatable {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.status,
    required this.createdAt,
    required this.items,
    required this.shippingAddress,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    this.paymentMethodLabel,
    this.shippingMethodLabel,
  });

  final String id;
  final String orderNumber;
  final String customerId;
  final OrderStatus status;
  final DateTime createdAt;
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
    id,
    orderNumber,
    customerId,
    status,
    createdAt,
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

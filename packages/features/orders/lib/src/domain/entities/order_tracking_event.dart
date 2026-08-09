import 'package:equatable/equatable.dart';

import 'order_status.dart';

/// A single chronologically ordered tracking milestone for an order.
final class OrderTrackingEvent extends Equatable {
  const OrderTrackingEvent({
    required this.id,
    required this.status,
    required this.title,
    required this.occurredAt,
    this.description,
  });

  final String id;
  final OrderStatus status;
  final String title;
  final String? description;
  final DateTime occurredAt;

  @override
  List<Object?> get props => [id, status, title, description, occurredAt];
}

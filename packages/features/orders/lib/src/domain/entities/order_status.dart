/// Lifecycle status for a customer order.
enum OrderStatus {
  placed,
  processing,
  shipped,
  delivered,
  cancelled,
  returnRequested,
  returned;

  /// Human-readable label for badges and timelines.
  String get displayLabel => switch (this) {
    OrderStatus.placed => 'Placed',
    OrderStatus.processing => 'Processing',
    OrderStatus.shipped => 'Shipped',
    OrderStatus.delivered => 'Delivered',
    OrderStatus.cancelled => 'Cancelled',
    OrderStatus.returnRequested => 'Return requested',
    OrderStatus.returned => 'Returned',
  };

  /// Cancel is allowed only while the order is still early in fulfillment.
  bool get canCancel =>
      this == OrderStatus.placed || this == OrderStatus.processing;

  /// Returns are accepted only after the order has been delivered.
  bool get canRequestReturn => this == OrderStatus.delivered;

  /// Maps [SeedOrder.status] strings into domain statuses.
  ///
  /// Seed uses `pending` / `paid`; domain uses `placed` / `processing`.
  static OrderStatus fromSeed(String raw) {
    return switch (raw) {
      'pending' || 'placed' => OrderStatus.placed,
      'paid' || 'processing' => OrderStatus.processing,
      'shipped' => OrderStatus.shipped,
      'delivered' => OrderStatus.delivered,
      'cancelled' => OrderStatus.cancelled,
      'returnRequested' => OrderStatus.returnRequested,
      'returned' => OrderStatus.returned,
      _ => OrderStatus.placed,
    };
  }

  /// Seed-store string (`pending` for placed, `paid` for processing).
  String toSeed() {
    return switch (this) {
      OrderStatus.placed => 'pending',
      OrderStatus.processing => 'paid',
      OrderStatus.shipped => 'shipped',
      OrderStatus.delivered => 'delivered',
      OrderStatus.cancelled => 'cancelled',
      OrderStatus.returnRequested => 'returnRequested',
      OrderStatus.returned => 'returned',
    };
  }
}

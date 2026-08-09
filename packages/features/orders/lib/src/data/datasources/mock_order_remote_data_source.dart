import 'package:core/core.dart';

import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_tracking_event.dart';
import '../../domain/repositories/order_repository.dart';
import '../mappers/order_tracking_builder.dart';
import '../mappers/seed_order_mapper.dart';
import '../mock/order_call_types.dart';
import 'order_remote_data_source.dart';

/// In-memory overlay on [MockSeedStore.orders] (create appends).
///
/// Created orders are written into the shared seed store so get/list and
/// Developer Panel reset stay consistent. Labels live only on the domain
/// [Order] until seed models gain those fields.
final class MockOrderRemoteDataSource
    with MockDataSourceMixin
    implements OrderRemoteDataSource {
  MockOrderRemoteDataSource({
    required this.simulator,
    required MockSeedStore store,
    DateTime Function()? clock,
    // ignore: prefer_initializing_formals
  }) : _store = store,
       _clock = clock ?? DateTime.now;

  @override
  final MockNetworkSimulator simulator;

  final MockSeedStore _store;
  final DateTime Function() _clock;

  /// Domain-only fields (labels) keyed by order id.
  final Map<String, ({String? payment, String? shipping})> _labelOverlay = {};

  int _createCounter = 0;

  @override
  Future<Order> createOrder(CreateOrderRequest request) {
    return guarded(OrderCallTypes.create, () async {
      if (request.items.isEmpty) {
        throw const ValidationException({
          'items': 'Order must contain at least one item',
        }, 'Cannot place an empty order');
      }
      _createCounter += 1;
      final now = _clock().toUtc();
      final stamp = now.millisecondsSinceEpoch;
      final id = 'ord_checkout_${stamp}_$_createCounter';
      final orderNumber =
          'WL-${now.year}${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}-'
          '${_createCounter.toString().padLeft(4, '0')}';
      final order = SeedOrderMapper.fromCreateRequest(
        request: request,
        id: id,
        orderNumber: orderNumber,
        createdAt: now,
      );
      _store.orders.insert(0, SeedOrderMapper.toSeed(order));
      _labelOverlay[id] = (
        payment: request.paymentMethodLabel,
        shipping: request.shippingMethodLabel,
      );
      return order;
    });
  }

  @override
  Future<Order> fetchOrder(String orderId) {
    return guarded(OrderCallTypes.get, () async {
      return _requireOrder(orderId);
    });
  }

  @override
  Future<List<Order>> fetchOrders(String customerId) {
    return guarded(OrderCallTypes.list, () async {
      final orders = _store.orders
          .where((o) => o.customerId == customerId)
          .map((o) => _withLabels(SeedOrderMapper.toDomain(o)))
          .toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return List<Order>.unmodifiable(orders);
    });
  }

  @override
  Future<List<OrderTrackingEvent>> fetchTrackingEvents(String orderId) {
    return guarded(OrderCallTypes.tracking, () async {
      final order = _requireOrder(orderId);
      return OrderTrackingBuilder.build(order);
    });
  }

  @override
  Future<Order> cancelOrder({
    required String orderId,
    required String customerId,
    required String reason,
  }) {
    return guarded(OrderCallTypes.cancel, () async {
      final trimmed = reason.trim();
      if (trimmed.isEmpty) {
        throw const ValidationException({
          'reason': 'Reason is required',
        }, 'Please provide a cancellation reason');
      }
      final index = _indexOfOwnedOrder(orderId, customerId);
      final current = SeedOrderMapper.toDomain(_store.orders[index]);
      if (!current.status.canCancel) {
        throw ValidationException({
          'status': 'Order status is ${current.status.displayLabel}',
        }, 'This order can no longer be cancelled');
      }
      return _mutateStatus(index, OrderStatus.cancelled);
    });
  }

  @override
  Future<Order> requestReturn({
    required String orderId,
    required String customerId,
    required String reason,
  }) {
    return guarded(OrderCallTypes.requestReturn, () async {
      final trimmed = reason.trim();
      if (trimmed.isEmpty) {
        throw const ValidationException({
          'reason': 'Reason is required',
        }, 'Please provide a return reason');
      }
      final index = _indexOfOwnedOrder(orderId, customerId);
      final current = SeedOrderMapper.toDomain(_store.orders[index]);
      if (!current.status.canRequestReturn) {
        throw ValidationException({
          'status': 'Order status is ${current.status.displayLabel}',
        }, 'Returns are only available for delivered orders');
      }
      return _mutateStatus(index, OrderStatus.returnRequested);
    });
  }

  int _indexOfOwnedOrder(String orderId, String customerId) {
    final index = _store.orders.indexWhere((o) => o.id == orderId);
    if (index < 0) {
      throw NotFoundException('Order not found: $orderId');
    }
    final seed = _store.orders[index];
    if (seed.customerId != customerId) {
      throw const UnauthorizedException('You do not have access to this order');
    }
    return index;
  }

  Order _requireOrder(String orderId) {
    final match = _store.orders.where((o) => o.id == orderId);
    if (match.isEmpty) {
      throw NotFoundException('Order not found: $orderId');
    }
    return _withLabels(SeedOrderMapper.toDomain(match.first));
  }

  Order _mutateStatus(int index, OrderStatus status) {
    final seed = _store.orders[index];
    final updated = SeedOrder(
      id: seed.id,
      orderNumber: seed.orderNumber,
      customerId: seed.customerId,
      status: status.toSeed(),
      createdAtIso: seed.createdAtIso,
      items: seed.items,
      shippingAddress: seed.shippingAddress,
      subtotal: seed.subtotal,
      shipping: seed.shipping,
      tax: seed.tax,
      total: seed.total,
    );
    _store.orders[index] = updated;
    return _withLabels(SeedOrderMapper.toDomain(updated));
  }

  Order _withLabels(Order order) {
    final labels = _labelOverlay[order.id];
    if (labels == null) {
      return order;
    }
    return order.copyWith(
      paymentMethodLabel: labels.payment,
      shippingMethodLabel: labels.shipping,
    );
  }
}

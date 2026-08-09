import 'package:core/core.dart';

import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
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
      final match = _store.orders.where((o) => o.id == orderId);
      if (match.isEmpty) {
        throw NotFoundException('Order not found: $orderId');
      }
      return _withLabels(SeedOrderMapper.toDomain(match.first));
    });
  }

  @override
  Future<List<Order>> fetchOrders(String customerId) {
    return guarded(OrderCallTypes.list, () async {
      return _store.orders
          .where((o) => o.customerId == customerId)
          .map((o) => _withLabels(SeedOrderMapper.toDomain(o)))
          .toList(growable: false);
    });
  }

  Order _withLabels(Order order) {
    final labels = _labelOverlay[order.id];
    if (labels == null) {
      return order;
    }
    return Order(
      id: order.id,
      orderNumber: order.orderNumber,
      customerId: order.customerId,
      status: order.status,
      createdAt: order.createdAt,
      items: order.items,
      shippingAddress: order.shippingAddress,
      subtotal: order.subtotal,
      shipping: order.shipping,
      tax: order.tax,
      total: order.total,
      paymentMethodLabel: labels.payment,
      shippingMethodLabel: labels.shipping,
    );
  }
}

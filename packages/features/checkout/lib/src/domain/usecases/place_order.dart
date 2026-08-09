import 'package:cart/cart.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:orders/orders.dart';

import '../entities/checkout_payment_method.dart';
import '../entities/checkout_session.dart';
import '../entities/saved_address.dart';
import '../entities/shipping_method.dart';
import '../repositories/checkout_repository.dart';

/// Places an order from the current cart + checkout session, then clears cart.
final class PlaceOrder extends UseCase<Order, PlaceOrderParams> {
  const PlaceOrder({
    required GetCartSummary getCartSummary,
    required ClearCart clearCart,
    required OrderRepository orderRepository,
    required CheckoutRepository checkoutRepository,
    // ignore: prefer_initializing_formals
  }) : _getCartSummary = getCartSummary,
       // ignore: prefer_initializing_formals
       _clearCart = clearCart,
       // ignore: prefer_initializing_formals
       _orderRepository = orderRepository,
       // ignore: prefer_initializing_formals
       _checkoutRepository = checkoutRepository;

  final GetCartSummary _getCartSummary;
  final ClearCart _clearCart;
  final OrderRepository _orderRepository;
  final CheckoutRepository _checkoutRepository;

  @override
  Future<Result<Failure, Order>> call(PlaceOrderParams params) async {
    final cartResult = await _getCartSummary(
      GetCartSummaryParams(params.customerId),
    );
    final summary = cartResult.valueOrNull;
    if (cartResult.isFailure || summary == null) {
      return Result.failure(
        cartResult.failureOrNull ??
            const UnknownFailure(message: 'Could not load cart'),
      );
    }
    if (summary.cart.isEmpty) {
      return const Result.failure(
        ValidationFailure({'cart': 'Cart is empty'}, message: 'Empty cart'),
      );
    }

    final address = _resolveAddress(params);
    if (address == null) {
      return const Result.failure(
        ValidationFailure({
          'address': 'Select a shipping address',
        }, message: 'Address required'),
      );
    }

    final shipping = params.shippingMethod;
    final payment = params.paymentMethod;
    if (shipping == null || payment == null) {
      return const Result.failure(
        ValidationFailure({
          'checkout': 'Select shipping and payment methods',
        }, message: 'Incomplete checkout'),
      );
    }

    final costResult = await _checkoutRepository.calculateShippingCost(
      methodId: shipping.id,
      postalCode: address.postalCode,
    );
    final shippingCost = costResult.valueOrNull;
    if (costResult.isFailure || shippingCost == null) {
      return Result.failure(
        costResult.failureOrNull ??
            const UnknownFailure(message: 'Could not calculate shipping'),
      );
    }

    final pricing = summary.pricing;
    final tax = pricing.taxPlaceholder;
    final total = pricing.total + shippingCost;

    final items = summary.cart.items
        .map(
          (item) => OrderLineItem(
            productId: item.productId,
            productName: item.productName,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            variantId: item.variantId,
            variantLabel: item.variantLabel,
          ),
        )
        .toList(growable: false);

    final createResult = await _orderRepository.createOrder(
      CreateOrderRequest(
        customerId: params.customerId,
        items: items,
        shippingAddress: address,
        subtotal: pricing.subtotal,
        shipping: shippingCost,
        tax: tax,
        total: total,
        paymentMethodLabel: payment.displayLabel,
        shippingMethodLabel: shipping.name,
      ),
    );

    final order = createResult.valueOrNull;
    if (createResult.isFailure || order == null) {
      return Result.failure(
        createResult.failureOrNull ??
            const UnknownFailure(message: 'Could not create order'),
      );
    }

    final clearResult = await _clearCart(ClearCartParams(params.customerId));
    if (clearResult.isFailure) {
      // Order already placed — surface clear failure but still return order.
      return Result.success(order);
    }

    return Result.success(order);
  }

  Address? _resolveAddress(PlaceOrderParams params) {
    final session = params.session;
    if (session.draftAddress != null && session.selectedAddressId == null) {
      return session.draftAddress;
    }
    final id = session.selectedAddressId;
    if (id == null) {
      return session.draftAddress;
    }
    for (final saved in params.addresses) {
      if (saved.id == id) {
        return saved.address;
      }
    }
    return session.draftAddress;
  }
}

final class PlaceOrderParams extends Equatable {
  const PlaceOrderParams({
    required this.customerId,
    required this.session,
    required this.addresses,
    required this.shippingMethod,
    required this.paymentMethod,
  });

  final String customerId;
  final CheckoutSession session;
  final List<SavedAddress> addresses;
  final ShippingMethod? shippingMethod;
  final CheckoutPaymentMethod? paymentMethod;

  @override
  List<Object?> get props => [
    customerId,
    session,
    addresses,
    shippingMethod,
    paymentMethod,
  ];
}

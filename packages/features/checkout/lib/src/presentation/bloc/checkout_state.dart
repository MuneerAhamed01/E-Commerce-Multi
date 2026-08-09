import 'package:cart/cart.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/checkout_payment_method.dart';
import '../../domain/entities/checkout_session.dart';
import '../../domain/entities/saved_address.dart';
import '../../domain/entities/shipping_method.dart';

sealed class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

final class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

final class CheckoutReady extends CheckoutState {
  const CheckoutReady({
    required this.session,
    required this.addresses,
    required this.shippingMethods,
    required this.paymentMethods,
    required this.cartSummary,
    this.shippingCost,
    this.stepError,
    this.shippingError,
  });

  final CheckoutSession session;
  final List<SavedAddress> addresses;
  final List<ShippingMethod> shippingMethods;
  final List<CheckoutPaymentMethod> paymentMethods;
  final CartSummary cartSummary;
  final Money? shippingCost;
  final String? stepError;
  final String? shippingError;

  SavedAddress? get selectedAddress {
    final id = session.selectedAddressId;
    if (id == null) {
      return null;
    }
    for (final address in addresses) {
      if (address.id == id) {
        return address;
      }
    }
    return null;
  }

  ShippingMethod? get selectedShipping {
    final id = session.shippingMethodId;
    if (id == null) {
      return null;
    }
    for (final method in shippingMethods) {
      if (method.id == id) {
        return method;
      }
    }
    return null;
  }

  CheckoutPaymentMethod? get selectedPayment {
    final id = session.paymentMethodId;
    if (id == null) {
      return null;
    }
    for (final method in paymentMethods) {
      if (method.id == id) {
        return method;
      }
    }
    return null;
  }

  Address? get effectiveAddress =>
      selectedAddress?.address ?? session.draftAddress;

  Money get orderTotal {
    final base = cartSummary.pricing.total;
    final ship = shippingCost ?? Money.zero(base.currencyCode);
    return base + ship;
  }

  CheckoutReady copyWith({
    CheckoutSession? session,
    List<SavedAddress>? addresses,
    List<ShippingMethod>? shippingMethods,
    List<CheckoutPaymentMethod>? paymentMethods,
    CartSummary? cartSummary,
    Money? shippingCost,
    String? stepError,
    String? shippingError,
    bool clearStepError = false,
    bool clearShippingError = false,
    bool clearShippingCost = false,
  }) {
    return CheckoutReady(
      session: session ?? this.session,
      addresses: addresses ?? this.addresses,
      shippingMethods: shippingMethods ?? this.shippingMethods,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      cartSummary: cartSummary ?? this.cartSummary,
      shippingCost: clearShippingCost
          ? null
          : (shippingCost ?? this.shippingCost),
      stepError: clearStepError ? null : (stepError ?? this.stepError),
      shippingError: clearShippingError
          ? null
          : (shippingError ?? this.shippingError),
    );
  }

  @override
  List<Object?> get props => [
    session,
    addresses,
    shippingMethods,
    paymentMethods,
    cartSummary,
    shippingCost,
    stepError,
    shippingError,
  ];
}

final class CheckoutPlacing extends CheckoutState {
  const CheckoutPlacing(this.ready);

  final CheckoutReady ready;

  @override
  List<Object?> get props => [ready];
}

final class CheckoutPlaced extends CheckoutState {
  const CheckoutPlaced({required this.orderId, required this.orderNumber});

  final String orderId;
  final String orderNumber;

  @override
  List<Object?> get props => [orderId, orderNumber];
}

final class CheckoutError extends CheckoutState {
  const CheckoutError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

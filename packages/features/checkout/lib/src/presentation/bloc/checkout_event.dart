import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

sealed class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

final class CheckoutStarted extends CheckoutEvent {
  const CheckoutStarted();
}

final class CheckoutAddressSelected extends CheckoutEvent {
  const CheckoutAddressSelected(this.addressId);

  final String addressId;

  @override
  List<Object?> get props => [addressId];
}

final class CheckoutAddressSaved extends CheckoutEvent {
  const CheckoutAddressSaved(this.address);

  final Address address;

  @override
  List<Object?> get props => [address];
}

final class CheckoutContinueFromAddress extends CheckoutEvent {
  const CheckoutContinueFromAddress();
}

final class CheckoutShippingSelected extends CheckoutEvent {
  const CheckoutShippingSelected(this.methodId);

  final String methodId;

  @override
  List<Object?> get props => [methodId];
}

final class CheckoutPaymentSelected extends CheckoutEvent {
  const CheckoutPaymentSelected(this.methodId);

  final String methodId;

  @override
  List<Object?> get props => [methodId];
}

final class CheckoutContinueFromShippingPayment extends CheckoutEvent {
  const CheckoutContinueFromShippingPayment();
}

final class CheckoutPlaceOrderRequested extends CheckoutEvent {
  const CheckoutPlaceOrderRequested();
}

final class CheckoutRetried extends CheckoutEvent {
  const CheckoutRetried();
}

final class CheckoutReset extends CheckoutEvent {
  const CheckoutReset();
}

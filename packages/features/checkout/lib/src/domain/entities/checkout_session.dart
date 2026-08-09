import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

/// Snapshot of wizard selections spanning checkout steps.
final class CheckoutSession extends Equatable {
  const CheckoutSession({
    this.selectedAddressId,
    this.shippingMethodId,
    this.paymentMethodId,
    this.draftAddress,
  });

  final String? selectedAddressId;
  final String? shippingMethodId;
  final String? paymentMethodId;
  final Address? draftAddress;

  bool get hasAddress => selectedAddressId != null || draftAddress != null;
  bool get hasShipping => shippingMethodId != null;
  bool get hasPayment => paymentMethodId != null;
  bool get canReview => hasAddress && hasShipping && hasPayment;

  CheckoutSession copyWith({
    String? selectedAddressId,
    String? shippingMethodId,
    String? paymentMethodId,
    Address? draftAddress,
    bool clearAddressId = false,
    bool clearShipping = false,
    bool clearPayment = false,
    bool clearDraft = false,
  }) {
    return CheckoutSession(
      selectedAddressId: clearAddressId
          ? null
          : (selectedAddressId ?? this.selectedAddressId),
      shippingMethodId: clearShipping
          ? null
          : (shippingMethodId ?? this.shippingMethodId),
      paymentMethodId: clearPayment
          ? null
          : (paymentMethodId ?? this.paymentMethodId),
      draftAddress: clearDraft ? null : (draftAddress ?? this.draftAddress),
    );
  }

  @override
  List<Object?> get props => [
    selectedAddressId,
    shippingMethodId,
    paymentMethodId,
    draftAddress,
  ];
}

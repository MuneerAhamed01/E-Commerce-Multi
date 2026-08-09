import 'package:equatable/equatable.dart';

/// Kind of checkout payment method (local Phase 14 contract).
///
/// **Deviation:** Full Payments package is Phase 16 — this minimal entity
/// lives in checkout so 14.3 can select a method without `payments`.
enum CheckoutPaymentType { card, cod, wallet }

/// Selectable payment method for the shipping/payment step.
final class CheckoutPaymentMethod extends Equatable {
  const CheckoutPaymentMethod({
    required this.id,
    required this.brandLabel,
    required this.type,
    this.last4,
    this.isDefault = false,
  });

  final String id;
  final String brandLabel;
  final String? last4;
  final CheckoutPaymentType type;
  final bool isDefault;

  String get displayLabel {
    if (type == CheckoutPaymentType.cod) {
      return brandLabel;
    }
    if (last4 != null && last4!.isNotEmpty) {
      return '$brandLabel ••••$last4';
    }
    return brandLabel;
  }

  @override
  List<Object?> get props => [id, brandLabel, last4, type, isDefault];
}

import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

/// Authoritative cart totals (subtotal / discount / tax placeholder / total).
final class PricingBreakdown extends Equatable {
  const PricingBreakdown({
    required this.subtotal,
    required this.discount,
    required this.taxPlaceholder,
    required this.total,
  });

  factory PricingBreakdown.zero(String currencyCode) {
    final zero = Money.zero(currencyCode);
    return PricingBreakdown(
      subtotal: zero,
      discount: zero,
      taxPlaceholder: zero,
      total: zero,
    );
  }

  final Money subtotal;
  final Money discount;

  /// Tax is not calculated in Phase 13 — always zero placeholder.
  final Money taxPlaceholder;
  final Money total;

  @override
  List<Object?> get props => [subtotal, discount, taxPlaceholder, total];
}

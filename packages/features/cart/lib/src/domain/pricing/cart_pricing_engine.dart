import 'package:core/core.dart';

import '../entities/cart.dart';
import '../entities/cart_item.dart';
import '../entities/pricing_breakdown.dart';
import '../entities/promo_definition.dart';

/// Pure pricing math for cart totals.
///
/// **Stacked discounts policy:** at most one promo may apply. Callers must
/// replace (not stack) when applying a new code.
abstract final class CartPricingEngine {
  /// Computes [PricingBreakdown] for [cart] with an optional resolved promo.
  ///
  /// [promo] should already be validated (not expired / min-spend met); this
  /// method still clamps discount so it never exceeds subtotal.
  static PricingBreakdown compute(Cart cart, {PromoDefinition? promo}) {
    final currency = cart.currencyCode;
    if (cart.items.isEmpty) {
      return PricingBreakdown.zero(currency);
    }

    final subtotal = cart.subtotal;
    var discount = Money.zero(currency);

    if (promo != null) {
      discount = _discountFor(subtotal: subtotal, promo: promo);
      if (discount > subtotal) {
        discount = subtotal;
      }
    }

    final taxPlaceholder = Money.zero(currency);
    final total = subtotal - discount + taxPlaceholder;
    return PricingBreakdown(
      subtotal: subtotal,
      discount: discount,
      taxPlaceholder: taxPlaceholder,
      total: total,
    );
  }

  /// Validates quantity against stock rules.
  ///
  /// - Quantity must be ≥ 1 (zero qty blocked — use remove instead).
  /// - Quantity must be ≤ [maxStock].
  static ValidationFailure? validateQuantity({
    required int quantity,
    required int maxStock,
  }) {
    if (quantity < 1) {
      return const ValidationFailure({
        'quantity': 'Quantity must be at least 1',
      }, message: 'Zero quantity is not allowed');
    }
    if (maxStock < 1) {
      return const ValidationFailure({
        'quantity': 'Out of stock',
      }, message: 'This item is out of stock');
    }
    if (quantity > maxStock) {
      return ValidationFailure({
        'quantity': 'Only $maxStock available',
      }, message: 'Quantity exceeds available stock ($maxStock)');
    }
    return null;
  }

  /// Caps [desired] at [maxStock] (never below 1 when stock allows).
  static int capQuantity(int desired, int maxStock) {
    if (maxStock < 1) {
      return 0;
    }
    if (desired < 1) {
      return 1;
    }
    return desired > maxStock ? maxStock : desired;
  }

  static Money _discountFor({
    required Money subtotal,
    required PromoDefinition promo,
  }) {
    switch (promo.kind) {
      case PromoKind.percentOff:
        final percent = promo.percentOff ?? 0;
        return subtotal * (percent / 100);
      case PromoKind.fixedAmount:
        return promo.fixedAmount ?? Money.zero(subtotal.currencyCode);
    }
  }
}

/// Result of validating a promo against a cart subtotal.
sealed class PromoValidationResult {
  const PromoValidationResult();
}

final class PromoValidationSuccess extends PromoValidationResult {
  const PromoValidationSuccess(this.promo);
  final PromoDefinition promo;
}

final class PromoValidationFailure extends PromoValidationResult {
  const PromoValidationFailure(this.message, {this.field = 'promoCode'});
  final String message;
  final String field;

  ValidationFailure toFailure() =>
      ValidationFailure({field: message}, message: message);
}

/// Validates a raw code against the local mock catalog.
abstract final class PromoValidator {
  static PromoValidationResult validate({
    required String rawCode,
    required Money subtotal,
    required Map<String, PromoDefinition> catalog,
    DateTime Function()? clock,
  }) {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) {
      return const PromoValidationFailure('Enter a promo code');
    }

    final promo = catalog[code];
    if (promo == null) {
      return const PromoValidationFailure('Invalid promo code');
    }

    final now = (clock ?? DateTime.now)().toUtc();
    final expiry = promo.expiresAt;
    if (expiry != null && now.isAfter(expiry.toUtc())) {
      return const PromoValidationFailure('This promo code has expired');
    }

    final minSpend = promo.minSpend;
    if (minSpend != null && subtotal < minSpend) {
      return PromoValidationFailure(
        'Minimum spend of ${Formatters.currency(minSpend)} not met',
      );
    }

    return PromoValidationSuccess(promo);
  }
}

/// Helper used by tests to build a cart with known lines.
CartItem testLine({
  required String productId,
  required Money unitPrice,
  required int quantity,
  int maxStock = 99,
  String variantId = 'var',
}) {
  return CartItem(
    productId: productId,
    variantId: variantId,
    productName: productId,
    variantLabel: 'Default',
    unitPrice: unitPrice,
    quantity: quantity,
    maxStock: maxStock,
  );
}

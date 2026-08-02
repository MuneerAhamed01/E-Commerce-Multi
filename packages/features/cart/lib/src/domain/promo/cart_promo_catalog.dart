import 'package:core/core.dart';

import '../entities/promo_definition.dart';

/// Seeded promo codes for cart QA (local mock until Marketing owns coupons).
///
/// | Code | Behavior |
/// |---|---|
/// | `SAVE10` | 10% off |
/// | `SAVE5` | $5.00 fixed off |
/// | `EXPIRED` | Always expired |
/// | `NOSPEND` | Requires $100.00 min spend |
/// | `INVALID` | Not in catalog — treated as invalid |
abstract final class CartPromoCatalog {
  static const String save10 = 'SAVE10';
  static const String save5 = 'SAVE5';
  static const String expired = 'EXPIRED';
  static const String noSpend = 'NOSPEND';

  /// Intentionally absent from [definitions] so apply fails as invalid.
  static const String invalid = 'INVALID';

  static Map<String, PromoDefinition> definitions({
    DateTime Function()? clock,
  }) {
    final now = (clock ?? DateTime.now)().toUtc();
    return {
      save10: const PromoDefinition(
        code: save10,
        kind: PromoKind.percentOff,
        percentOff: 10,
      ),
      save5: const PromoDefinition(
        code: save5,
        kind: PromoKind.fixedAmount,
        fixedAmount: Money(minorUnits: 500, currencyCode: 'USD'),
      ),
      expired: PromoDefinition(
        code: expired,
        kind: PromoKind.percentOff,
        percentOff: 20,
        expiresAt: now.subtract(const Duration(days: 1)),
      ),
      noSpend: const PromoDefinition(
        code: noSpend,
        kind: PromoKind.percentOff,
        percentOff: 15,
        minSpend: Money(minorUnits: 10000, currencyCode: 'USD'),
      ),
    };
  }
}

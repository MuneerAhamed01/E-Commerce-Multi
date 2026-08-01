import 'package:equatable/equatable.dart';

/// An immutable monetary amount: an integer count of a currency's smallest
/// unit (e.g. cents for USD) plus an ISO 4217 currency code.
///
/// Storing [minorUnits] as an integer (never a `double`) avoids
/// floating-point rounding errors in prices/totals - the #1 source of
/// off-by-a-cent bugs in commerce apps. This is a genuinely cross-feature
/// concept with no single owner (Products, Cart, Checkout, Orders, Admin
/// Catalog all use it), so it lives in `core` per
/// docs/05_ARCHITECTURE_GUIDELINES.md §3.
///
/// Assumes a 2-decimal-place currency (matching this plan's target
/// currencies). Supporting currencies with a different number of decimal
/// places is a documented, additive future extension - see
/// docs/05_ARCHITECTURE_GUIDELINES.md §17.
final class Money extends Equatable implements Comparable<Money> {
  const Money({required this.minorUnits, required this.currencyCode});

  /// A zero amount in [currencyCode] - a safe default for running totals.
  factory Money.zero(String currencyCode) =>
      Money(minorUnits: 0, currencyCode: currencyCode);

  /// The amount, expressed in the currency's smallest unit (e.g. cents).
  final int minorUnits;

  /// ISO 4217 currency code, e.g. `'USD'`.
  final String currencyCode;

  /// The amount as a decimal major-unit value (e.g. dollars), for display
  /// formatting only - never use this for further arithmetic (accumulate
  /// [minorUnits] instead to avoid rounding drift).
  double get majorUnits => minorUnits / 100;

  /// Whether this amount is zero.
  bool get isZero => minorUnits == 0;

  /// Whether this amount is negative (e.g. a refund/credit).
  bool get isNegative => minorUnits < 0;

  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(
      minorUnits: minorUnits + other.minorUnits,
      currencyCode: currencyCode,
    );
  }

  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(
      minorUnits: minorUnits - other.minorUnits,
      currencyCode: currencyCode,
    );
  }

  /// Scales this amount by [factor] (e.g. quantity, a discount ratio),
  /// rounding to the nearest minor unit.
  Money operator *(num factor) {
    return Money(
      minorUnits: (minorUnits * factor).round(),
      currencyCode: currencyCode,
    );
  }

  bool operator <(Money other) => compareTo(other) < 0;

  bool operator <=(Money other) => compareTo(other) <= 0;

  bool operator >(Money other) => compareTo(other) > 0;

  bool operator >=(Money other) => compareTo(other) >= 0;

  @override
  int compareTo(Money other) {
    _assertSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  void _assertSameCurrency(Money other) {
    if (other.currencyCode != currencyCode) {
      throw ArgumentError(
        'Cannot combine Money in different currencies: '
        '$currencyCode vs ${other.currencyCode}',
      );
    }
  }

  @override
  List<Object?> get props => [minorUnits, currencyCode];
}

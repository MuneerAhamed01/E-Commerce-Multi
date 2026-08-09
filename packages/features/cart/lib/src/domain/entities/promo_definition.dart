import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

/// Local mock coupon definition (Marketing package owns this in Phase 25).
///
/// **Deviation:** promo validation lives inside cart until Marketing ships
/// `ValidateCoupon`.
enum PromoKind { percentOff, fixedAmount }

final class PromoDefinition extends Equatable {
  const PromoDefinition({
    required this.code,
    required this.kind,
    this.percentOff,
    this.fixedAmount,
    this.expiresAt,
    this.minSpend,
  });

  /// Canonical uppercase code (e.g. `SAVE10`).
  final String code;
  final PromoKind kind;

  /// Whole-number percent for [PromoKind.percentOff] (e.g. `10` → 10%).
  final int? percentOff;
  final Money? fixedAmount;
  final DateTime? expiresAt;
  final Money? minSpend;

  bool get isExpired {
    final expiry = expiresAt;
    if (expiry == null) {
      return false;
    }
    return DateTime.now().toUtc().isAfter(expiry.toUtc());
  }

  @override
  List<Object?> get props => [
    code,
    kind,
    percentOff,
    fixedAmount,
    expiresAt,
    minSpend,
  ];
}

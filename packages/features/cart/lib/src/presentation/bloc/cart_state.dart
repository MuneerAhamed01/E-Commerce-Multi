import 'package:equatable/equatable.dart';

import '../../domain/entities/cart.dart';
import '../../domain/entities/pricing_breakdown.dart';

sealed class CartState extends Equatable {
  const CartState();

  /// Sum of quantities for the shell badge (0 when not loaded).
  int get itemCount => 0;

  @override
  List<Object?> get props => [];
}

final class CartInitial extends CartState {
  const CartInitial();
}

final class CartLoading extends CartState {
  const CartLoading({this.previous});

  final CartLoaded? previous;

  @override
  int get itemCount => previous?.itemCount ?? 0;

  @override
  List<Object?> get props => [previous];
}

final class CartLoaded extends CartState {
  const CartLoaded({
    required this.summary,
    this.promoError,
    this.isApplyingPromo = false,
    this.statusMessage,
    this.checkoutMessage,
  });

  final CartSummary summary;
  final String? promoError;
  final bool isApplyingPromo;
  final String? statusMessage;

  /// Soft fallback when [CartScreen.onCheckoutNavigate] is not wired.
  final String? checkoutMessage;

  Cart get cart => summary.cart;
  PricingBreakdown get pricing => summary.pricing;

  @override
  int get itemCount => summary.itemCount;

  CartLoaded copyWith({
    CartSummary? summary,
    String? promoError,
    bool? isApplyingPromo,
    String? statusMessage,
    String? checkoutMessage,
    bool clearPromoError = false,
    bool clearStatusMessage = false,
    bool clearCheckoutMessage = false,
  }) {
    return CartLoaded(
      summary: summary ?? this.summary,
      promoError: clearPromoError ? null : (promoError ?? this.promoError),
      isApplyingPromo: isApplyingPromo ?? this.isApplyingPromo,
      statusMessage: clearStatusMessage
          ? null
          : (statusMessage ?? this.statusMessage),
      checkoutMessage: clearCheckoutMessage
          ? null
          : (checkoutMessage ?? this.checkoutMessage),
    );
  }

  @override
  List<Object?> get props => [
    summary,
    promoError,
    isApplyingPromo,
    statusMessage,
    checkoutMessage,
  ];
}

final class CartError extends CartState {
  const CartError(this.message, {this.itemCountHint = 0});

  final String message;
  final int itemCountHint;

  @override
  int get itemCount => itemCountHint;

  @override
  List<Object?> get props => [message, itemCountHint];
}

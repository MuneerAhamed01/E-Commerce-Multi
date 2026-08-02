import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import 'cart_item.dart';
import 'pricing_breakdown.dart';

/// Aggregate cart root for a guest or authenticated owner.
final class Cart extends Equatable {
  const Cart({
    required this.ownerId,
    required this.items,
    this.appliedPromoCode,
    this.currencyCode = 'USD',
  });

  factory Cart.empty(String ownerId, {String currencyCode = 'USD'}) {
    return Cart(ownerId: ownerId, items: const [], currencyCode: currencyCode);
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map<dynamic, dynamic>>()
              .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : <CartItem>[];
    return Cart(
      ownerId: json['ownerId'] as String,
      items: items,
      appliedPromoCode: json['appliedPromoCode'] as String?,
      currencyCode: json['currencyCode'] as String? ?? 'USD',
    );
  }

  final String ownerId;
  final List<CartItem> items;
  final String? appliedPromoCode;
  final String currencyCode;

  bool get isEmpty => items.isEmpty;

  /// Sum of line quantities (badge count).
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartItem? itemFor({required String productId, required String variantId}) {
    final key = '$productId::$variantId';
    for (final item in items) {
      if (item.lineKey == key) {
        return item;
      }
    }
    return null;
  }

  Money get subtotal {
    if (items.isEmpty) {
      return Money.zero(currencyCode);
    }
    return items.fold(
      Money.zero(currencyCode),
      (sum, item) => sum + item.lineTotal,
    );
  }

  Cart copyWith({
    String? ownerId,
    List<CartItem>? items,
    String? appliedPromoCode,
    String? currencyCode,
    bool clearPromo = false,
  }) {
    return Cart(
      ownerId: ownerId ?? this.ownerId,
      items: items ?? this.items,
      appliedPromoCode: clearPromo
          ? null
          : (appliedPromoCode ?? this.appliedPromoCode),
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  Map<String, dynamic> toJson() => {
    'ownerId': ownerId,
    'items': items.map((e) => e.toJson()).toList(),
    if (appliedPromoCode != null) 'appliedPromoCode': appliedPromoCode,
    'currencyCode': currencyCode,
  };

  @override
  List<Object?> get props => [ownerId, items, appliedPromoCode, currencyCode];
}

/// Cart + computed [PricingBreakdown] for presentation.
final class CartSummary extends Equatable {
  const CartSummary({required this.cart, required this.pricing});

  final Cart cart;
  final PricingBreakdown pricing;

  int get itemCount => cart.itemCount;

  @override
  List<Object?> get props => [cart, pricing];
}

import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

/// A single purchasable line in the cart (product + optional variant).
final class CartItem extends Equatable {
  const CartItem({
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.variantLabel,
    required this.unitPrice,
    required this.quantity,
    required this.maxStock,
    this.imageUrl = '',
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final priceJson = json['unitPrice'] as Map<String, dynamic>;
    return CartItem(
      productId: json['productId'] as String,
      variantId: json['variantId'] as String,
      productName: json['productName'] as String,
      variantLabel: json['variantLabel'] as String? ?? '',
      unitPrice: Money(
        minorUnits: (priceJson['minorUnits'] as num).toInt(),
        currencyCode: priceJson['currencyCode'] as String,
      ),
      quantity: (json['quantity'] as num).toInt(),
      maxStock: (json['maxStock'] as num).toInt(),
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  final String productId;
  final String variantId;
  final String productName;
  final String variantLabel;
  final Money unitPrice;
  final int quantity;
  final int maxStock;
  final String imageUrl;

  /// Stable line key for updates/removes.
  String get lineKey => '$productId::$variantId';

  Money get lineTotal => unitPrice * quantity;

  CartItem copyWith({
    String? productId,
    String? variantId,
    String? productName,
    String? variantLabel,
    Money? unitPrice,
    int? quantity,
    int? maxStock,
    String? imageUrl,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      productName: productName ?? this.productName,
      variantLabel: variantLabel ?? this.variantLabel,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      maxStock: maxStock ?? this.maxStock,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'variantId': variantId,
    'productName': productName,
    'variantLabel': variantLabel,
    'unitPrice': {
      'minorUnits': unitPrice.minorUnits,
      'currencyCode': unitPrice.currencyCode,
    },
    'quantity': quantity,
    'maxStock': maxStock,
    'imageUrl': imageUrl,
  };

  @override
  List<Object?> get props => [
    productId,
    variantId,
    productName,
    variantLabel,
    unitPrice,
    quantity,
    maxStock,
    imageUrl,
  ];
}

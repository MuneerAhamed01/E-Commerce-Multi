import 'package:equatable/equatable.dart';

/// A product (optionally a specific variant) saved by a user for later.
final class WishlistItem extends Equatable {
  const WishlistItem({
    required this.productId,
    required this.addedAt,
    this.variantId,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    final addedAtRaw = json['addedAt'];
    return WishlistItem(
      productId: json['productId'] as String,
      variantId: json['variantId'] as String?,
      addedAt: addedAtRaw is String
          ? DateTime.parse(addedAtRaw).toUtc()
          : DateTime.fromMillisecondsSinceEpoch(
              (addedAtRaw as num).toInt(),
              isUtc: true,
            ),
    );
  }

  final String productId;
  final String? variantId;
  final DateTime addedAt;

  WishlistItem copyWith({
    String? productId,
    String? variantId,
    DateTime? addedAt,
    bool clearVariantId = false,
  }) {
    return WishlistItem(
      productId: productId ?? this.productId,
      variantId: clearVariantId ? null : (variantId ?? this.variantId),
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    if (variantId != null) 'variantId': variantId,
    'addedAt': addedAt.toUtc().toIso8601String(),
  };

  @override
  List<Object?> get props => [productId, variantId, addedAt];
}

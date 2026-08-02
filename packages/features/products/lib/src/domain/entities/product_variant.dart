import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

/// A purchasable SKU of a [Product] (size/color/default).
final class ProductVariant extends Equatable {
  const ProductVariant({
    required this.id,
    required this.productId,
    required this.label,
    required this.sku,
    required this.price,
    required this.stock,
    this.attributes = const {},
    this.imageUrl = '',
  });

  final String id;
  final String productId;
  final String label;
  final String sku;
  final Money price;
  final int stock;

  /// Display attributes such as `size`, `color`.
  final Map<String, String> attributes;
  final String imageUrl;

  bool get isInStock => stock > 0;

  @override
  List<Object?> get props => [
    id,
    productId,
    label,
    sku,
    price,
    stock,
    attributes,
    imageUrl,
  ];
}

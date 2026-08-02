import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import 'product_image.dart';
import 'product_variant.dart';

/// Catalog product with variants, gallery, and aggregate rating.
final class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.categoryId,
    required this.images,
    required this.variants,
    required this.rating,
    required this.reviewCount,
    this.isFeatured = false,
  });

  final String id;
  final String name;
  final String slug;
  final String description;
  final String categoryId;
  final List<ProductImage> images;
  final List<ProductVariant> variants;

  /// Aggregate average rating (0–5).
  final double rating;
  final int reviewCount;
  final bool isFeatured;

  ProductVariant get defaultVariant =>
      variants.isNotEmpty ? variants.first : _missingVariant;

  ProductVariant? variantById(String variantId) {
    for (final variant in variants) {
      if (variant.id == variantId) {
        return variant;
      }
    }
    return null;
  }

  bool get hasMultipleVariants => variants.length > 1;

  /// Lowest list price among variants (for card display).
  ProductVariant get cheapestVariant {
    if (variants.isEmpty) {
      return _missingVariant;
    }
    return variants.reduce(
      (a, b) => a.price.minorUnits <= b.price.minorUnits ? a : b,
    );
  }

  ProductVariant get _missingVariant => ProductVariant(
    id: '${id}_missing',
    productId: id,
    label: 'Unavailable',
    sku: 'N/A',
    price: Money.zero('USD'),
    stock: 0,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    description,
    categoryId,
    images,
    variants,
    rating,
    reviewCount,
    isFeatured,
  ];
}

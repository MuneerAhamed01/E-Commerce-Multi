import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

/// Lightweight product tile for the home featured row.
///
/// Phase 8 deviation: owned by `dashboard` until `packages/features/products`
/// ships a shared domain entity (Phase 9).
final class FeaturedProduct extends Equatable {
  const FeaturedProduct({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    this.imageUrl = '',
    this.rating = 0,
  });

  final String id;
  final String name;
  final String slug;
  final Money price;
  final String imageUrl;
  final double rating;

  @override
  List<Object?> get props => [id, name, slug, price, imageUrl, rating];
}

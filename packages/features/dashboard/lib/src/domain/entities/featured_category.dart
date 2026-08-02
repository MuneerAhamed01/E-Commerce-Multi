import 'package:equatable/equatable.dart';

/// Lightweight category tile for the home featured row.
///
/// Phase 8 deviation: owned by `dashboard` until `packages/features/categories`
/// ships a shared domain entity (Phase 10).
final class FeaturedCategory extends Equatable {
  const FeaturedCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl = '',
  });

  final String id;
  final String name;
  final String slug;
  final String imageUrl;

  @override
  List<Object?> get props => [id, name, slug, imageUrl];
}

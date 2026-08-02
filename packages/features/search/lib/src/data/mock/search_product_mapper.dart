import 'package:core/core.dart';
import 'package:products/products.dart';

/// Maps [SeedProduct] → [Product] for search matching (display-ready cards).
///
/// Kept local to avoid importing products' private catalog builder
/// (`implementation_imports` lint).
abstract final class SearchProductMapper {
  static Product fromSeed(SeedProduct seed) {
    final imageUrl = seed.imageUrl.isEmpty
        ? 'https://cdn.example.com/products/${seed.id}.jpg'
        : seed.imageUrl;
    return Product(
      id: seed.id,
      name: seed.name,
      slug: seed.slug,
      description: seed.description,
      categoryId: seed.categoryId,
      images: [ProductImage(url: imageUrl, alt: seed.name)],
      variants: [
        ProductVariant(
          id: '${seed.id}_default',
          productId: seed.id,
          label: 'Default',
          sku: seed.sku,
          price: seed.price,
          stock: seed.stock,
        ),
      ],
      rating: seed.rating,
      reviewCount: seed.reviewCount,
      isFeatured: seed.isFeatured,
    );
  }
}

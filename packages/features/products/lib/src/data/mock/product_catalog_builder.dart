import 'package:core/core.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/product_image.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/entities/review.dart';

/// Maps [SeedProduct] → domain [Product] and synthesizes variants/reviews.
abstract final class ProductCatalogBuilder {
  /// Products whose numeric id ends with these digits get rich size/color
  /// variants (multi-variant demos).
  static bool isMultiVariantDemo(String productId) {
    final num = _numericSuffix(productId);
    return num % 5 == 0;
  }

  static Product fromSeed(SeedProduct seed) {
    final images = _imagesFor(seed);
    final variants = _variantsFor(seed, images);
    return Product(
      id: seed.id,
      name: seed.name,
      slug: seed.slug,
      description: seed.description,
      categoryId: seed.categoryId,
      images: images,
      variants: variants,
      rating: seed.rating,
      reviewCount: seed.reviewCount,
      isFeatured: seed.isFeatured,
    );
  }

  /// Deterministic pre-seeded reviews derived from product id.
  static List<Review> seedReviewsFor(SeedProduct seed) {
    final count = seed.reviewCount.clamp(0, 12);
    if (count == 0) {
      return const [];
    }
    final reviews = <Review>[];
    final base = _numericSuffix(seed.id);
    for (var i = 0; i < count; i++) {
      final rating = 3 + ((base + i) % 3);
      reviews.add(
        Review(
          id: '${seed.id}_rev_$i',
          productId: seed.id,
          userId: 'user_seed_${(base + i) % 40}',
          userDisplayName: _reviewerNames[(base + i) % _reviewerNames.length],
          rating: rating,
          title: rating >= 4 ? 'Great product' : 'Decent, with caveats',
          body:
              'Seeded review #$i for ${seed.name}. '
              'Helpful for catalog QA without Firebase.',
          createdAt: DateTime.utc(2025).add(Duration(days: base + i * 3)),
        ),
      );
    }
    return reviews;
  }

  static List<ProductImage> _imagesFor(SeedProduct seed) {
    final base = seed.imageUrl.isNotEmpty
        ? seed.imageUrl
        : 'https://cdn.example.com/products/${seed.id}.jpg';
    final images = <ProductImage>[ProductImage(url: base, alt: seed.name)];
    if (isMultiVariantDemo(seed.id)) {
      images.add(
        ProductImage(
          url: base.replaceFirst('.jpg', '_alt.jpg'),
          alt: '${seed.name} alternate',
          sortOrder: 1,
        ),
      );
    }
    return images;
  }

  static List<ProductVariant> _variantsFor(
    SeedProduct seed,
    List<ProductImage> images,
  ) {
    final primaryImage = images.first.url;
    if (!isMultiVariantDemo(seed.id)) {
      // Default + one alt so every product has selectable variants.
      // When the seed product is fully OOS, keep the alt OOS too; otherwise
      // leave at least one purchasable option for Add-to-Cart demos.
      final altStock = seed.stock <= 0 ? 0 : (seed.stock ~/ 2).clamp(0, 40);
      return [
        ProductVariant(
          id: '${seed.id}_var_default',
          productId: seed.id,
          label: 'Default',
          sku: seed.sku,
          price: seed.price,
          stock: seed.stock,
          imageUrl: primaryImage,
        ),
        ProductVariant(
          id: '${seed.id}_var_alt',
          productId: seed.id,
          label: 'Alternate',
          sku: '${seed.sku}-ALT',
          price: Money(
            minorUnits: seed.price.minorUnits + 200,
            currencyCode: seed.price.currencyCode,
          ),
          stock: altStock,
          attributes: const {'finish': 'Matte'},
          imageUrl: images.length > 1 ? images[1].url : primaryImage,
        ),
      ];
    }

    // Size × color matrix for multi-variant demos; force one OOS option.
    const sizes = ['S', 'M', 'L'];
    const colors = ['Black', 'Navy'];
    final variants = <ProductVariant>[];
    var index = 0;
    for (final color in colors) {
      for (final size in sizes) {
        final stock = (index == 1)
            ? 0
            : ((seed.stock + index * 2) % 25) + (index == 0 ? 1 : 0);
        final priceBump = index * 150;
        variants.add(
          ProductVariant(
            id: '${seed.id}_var_${color.toLowerCase()}_$size',
            productId: seed.id,
            label: '$color / $size',
            sku: '${seed.sku}-${color.substring(0, 1)}$size',
            price: Money(
              minorUnits: seed.price.minorUnits + priceBump,
              currencyCode: seed.price.currencyCode,
            ),
            stock: stock,
            attributes: {'color': color, 'size': size},
            imageUrl: index.isEven || images.length < 2
                ? primaryImage
                : images[1].url,
          ),
        );
        index++;
      }
    }
    return variants;
  }

  static int _numericSuffix(String productId) {
    final digits = productId.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  static const _reviewerNames = [
    'Alex Kim',
    'Jordan Lee',
    'Sam Rivera',
    'Casey Morgan',
    'Riley Chen',
    'Taylor Brooks',
    'Jamie Ortiz',
    'Morgan Blake',
  ];
}

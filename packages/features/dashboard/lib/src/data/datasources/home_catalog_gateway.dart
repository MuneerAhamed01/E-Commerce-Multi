import '../../domain/entities/featured_category.dart';
import '../../domain/entities/featured_product.dart';

/// Reads featured catalog slices from [MockSeedStore] without importing
/// unfinished `products` / `categories` feature packages (Phase 8 deviation).
abstract interface class HomeCatalogGateway {
  Future<List<FeaturedCategory>> fetchFeaturedCategories({int limit = 8});

  Future<List<FeaturedProduct>> fetchFeaturedProducts({int limit = 8});
}

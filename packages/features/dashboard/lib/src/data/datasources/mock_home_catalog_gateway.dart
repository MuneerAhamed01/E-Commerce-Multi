import 'package:core/core.dart';

import '../../domain/entities/featured_category.dart';
import '../../domain/entities/featured_product.dart';
import '../mock/dashboard_call_types.dart';
import 'home_catalog_gateway.dart';

/// Maps [MockSeedStore] fixtures into home view models.
final class MockHomeCatalogGateway
    with MockDataSourceMixin
    implements HomeCatalogGateway {
  MockHomeCatalogGateway({
    required this.simulator,
    required MockSeedStore store,
  }) : _store = store; // ignore: prefer_initializing_formals

  @override
  final MockNetworkSimulator simulator;

  final MockSeedStore _store;

  @override
  Future<List<FeaturedCategory>> fetchFeaturedCategories({int limit = 8}) {
    return guarded(DashboardCallTypes.featuredCatalog, () async {
      final topLevel =
          _store.categories.where((c) => c.parentId == null).toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return topLevel
          .take(limit)
          .map(
            (c) => FeaturedCategory(
              id: c.id,
              name: c.name,
              slug: c.slug,
              imageUrl: 'https://cdn.example.com/categories/${c.slug}.jpg',
            ),
          )
          .toList(growable: false);
    });
  }

  @override
  Future<List<FeaturedProduct>> fetchFeaturedProducts({int limit = 8}) {
    return guarded(DashboardCallTypes.featuredCatalog, () async {
      final featured = _store.products.where((p) => p.isFeatured).toList();
      final source = featured.isNotEmpty
          ? featured
          : _store.products.take(limit).toList();
      return source
          .take(limit)
          .map(
            (p) => FeaturedProduct(
              id: p.id,
              name: p.name,
              slug: p.slug,
              price: p.price,
              imageUrl: p.imageUrl,
              rating: p.rating,
            ),
          )
          .toList(growable: false);
    });
  }
}

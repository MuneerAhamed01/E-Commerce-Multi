/// Storefront home / dashboard feature.
///
/// Only symbols exported here are a public contract other packages may depend
/// on (docs/02_PROJECT_STRUCTURE.md §6 / §11).
///
/// **Phase 8 deviation:** featured products/categories are read from
/// `MockSeedStore` via local gateways (`HomeCatalogGateway` / `BannerSource`)
/// because `products`, `categories`, and `marketing` packages are still stubs.
library;

export 'src/domain/entities/featured_category.dart';
export 'src/domain/entities/featured_product.dart';
export 'src/domain/entities/home_banner.dart';
export 'src/domain/entities/home_feed.dart';
export 'src/domain/repositories/home_feed_repository.dart';
export 'src/domain/usecases/get_home_feed.dart';
export 'src/injection/dashboard_injection.dart';
export 'src/presentation/bloc/home_bloc.dart';
export 'src/presentation/screens/home_screen.dart';

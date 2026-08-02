import 'package:equatable/equatable.dart';

import 'featured_category.dart';
import 'featured_product.dart';
import 'home_banner.dart';

/// Aggregate view model for the storefront home screen (not persisted).
final class HomeFeed extends Equatable {
  const HomeFeed({
    required this.banners,
    required this.featuredCategories,
    required this.featuredProducts,
  });

  final List<HomeBanner> banners;
  final List<FeaturedCategory> featuredCategories;
  final List<FeaturedProduct> featuredProducts;

  /// True when every section is empty (tenant has no featured content).
  bool get isEmpty =>
      banners.isEmpty && featuredCategories.isEmpty && featuredProducts.isEmpty;

  @override
  List<Object?> get props => [banners, featuredCategories, featuredProducts];
}

import '../../domain/entities/home_banner.dart';

/// Hardcoded banner fixtures for Phase 8 (marketing package is still a stub).
abstract final class HomeBannerSeed {
  static const List<HomeBanner> banners = [
    HomeBanner(
      id: 'banner_summer',
      title: 'Summer essentials',
      subtitle: 'Light layers and everyday wear, curated for the season.',
      imageUrl: 'https://cdn.example.com/banners/summer.jpg',
      targetKind: HomeBannerTargetKind.category,
      targetId: 'cat_apparel',
    ),
    HomeBanner(
      id: 'banner_tech',
      title: 'Tech picks',
      subtitle: 'Featured gadgets from the electronics catalog.',
      imageUrl: 'https://cdn.example.com/banners/tech.jpg',
      targetKind: HomeBannerTargetKind.product,
      targetId: 'prod_007',
    ),
    HomeBanner(
      id: 'banner_home',
      title: 'Home refresh',
      subtitle: 'Accents and kitchen staples for a calmer space.',
      imageUrl: 'https://cdn.example.com/banners/home.jpg',
      targetKind: HomeBannerTargetKind.category,
      targetId: 'cat_home',
    ),
  ];
}

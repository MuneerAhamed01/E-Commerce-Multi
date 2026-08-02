import '../../domain/entities/home_banner.dart';

/// Thin local banner source (Phase 8) — not the future marketing repository.
abstract interface class BannerSource {
  Future<List<HomeBanner>> fetchBanners();
}

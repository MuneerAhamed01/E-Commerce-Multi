import 'package:core/core.dart';

import '../../domain/entities/home_banner.dart';
import '../mock/dashboard_call_types.dart';
import '../mock/home_banner_seed.dart';
import 'banner_source.dart';

final class MockBannerSource with MockDataSourceMixin implements BannerSource {
  MockBannerSource({required this.simulator});

  @override
  final MockNetworkSimulator simulator;

  @override
  Future<List<HomeBanner>> fetchBanners() =>
      guarded(DashboardCallTypes.banners, () async => HomeBannerSeed.banners);
}

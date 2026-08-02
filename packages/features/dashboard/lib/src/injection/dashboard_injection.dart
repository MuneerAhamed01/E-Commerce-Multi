import 'package:core/core.dart';

import '../data/datasources/banner_source.dart';
import '../data/datasources/home_catalog_gateway.dart';
import '../data/datasources/mock_banner_source.dart';
import '../data/datasources/mock_home_catalog_gateway.dart';
import '../data/repositories/mock_home_feed_repository_impl.dart';
import '../domain/repositories/home_feed_repository.dart';
import '../domain/usecases/get_home_feed.dart';
import '../presentation/bloc/home_bloc.dart';

/// Registers storefront home dependencies.
///
/// Call **after** [configureMockInjection] so [MockNetworkSimulator] /
/// [MockSeedStore] exist. Safe to call once per process.
void configureDashboardInjection() {
  if (!getIt.isRegistered<MockNetworkSimulator>() ||
      !getIt.isRegistered<MockSeedStore>()) {
    throw StateError(
      'configureDashboardInjection() requires configureMockInjection() first.',
    );
  }

  if (!getIt.isRegistered<BannerSource>()) {
    getIt.registerLazySingleton<BannerSource>(
      () => MockBannerSource(simulator: getIt<MockNetworkSimulator>()),
    );
  }

  if (!getIt.isRegistered<HomeCatalogGateway>()) {
    getIt.registerLazySingleton<HomeCatalogGateway>(
      () => MockHomeCatalogGateway(
        simulator: getIt<MockNetworkSimulator>(),
        store: getIt<MockSeedStore>(),
      ),
    );
  }

  if (!getIt.isRegistered<HomeFeedRepository>()) {
    getIt.registerLazySingleton<HomeFeedRepository>(
      () => MockHomeFeedRepositoryImpl(
        bannerSource: getIt<BannerSource>(),
        catalogGateway: getIt<HomeCatalogGateway>(),
        simulator: getIt<MockNetworkSimulator>(),
      ),
    );
  }

  if (!getIt.isRegistered<GetHomeFeed>()) {
    getIt.registerFactory<GetHomeFeed>(
      () => GetHomeFeed(getIt<HomeFeedRepository>()),
    );
  }

  if (!getIt.isRegistered<HomeBloc>()) {
    getIt.registerFactory<HomeBloc>(() => HomeBloc(getHomeFeed: getIt()));
  }
}

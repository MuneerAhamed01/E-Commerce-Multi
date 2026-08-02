import 'dart:math';

import 'package:core/core.dart';
import 'package:dashboard/src/data/datasources/mock_banner_source.dart';
import 'package:dashboard/src/data/datasources/mock_home_catalog_gateway.dart';
import 'package:dashboard/src/data/repositories/mock_home_feed_repository_impl.dart';
import 'package:dashboard/src/domain/repositories/home_feed_repository.dart';
import 'package:dashboard/src/domain/usecases/get_home_feed.dart';
import 'package:dashboard/src/presentation/bloc/home_bloc.dart';

final class DashboardTestHarness {
  DashboardTestHarness._({
    required this.controls,
    required this.store,
    required this.repository,
    required this.getHomeFeed,
  });

  final MockDeveloperControls controls;
  final MockSeedStore store;
  final HomeFeedRepository repository;
  final GetHomeFeed getHomeFeed;

  static DashboardTestHarness create() {
    final controls = MockDeveloperControls()..latencyDisabled = true;
    final store = MockSeedStore(controls: controls);
    final simulator = MockNetworkSimulator(
      appConfig: const AppConfig(
        environment: Environment.dev,
        dataSourceMode: DataSourceMode.mock,
        logLevel: LogLevel.debug,
        mockLatencyMin: Duration.zero,
        mockLatencyMax: Duration.zero,
        isDeveloperModeAvailable: true,
      ),
      controls: controls,
      random: Random(0),
    );
    final bannerSource = MockBannerSource(simulator: simulator);
    final catalog = MockHomeCatalogGateway(simulator: simulator, store: store);
    final repository = MockHomeFeedRepositoryImpl(
      bannerSource: bannerSource,
      catalogGateway: catalog,
      simulator: simulator,
    );

    return DashboardTestHarness._(
      controls: controls,
      store: store,
      repository: repository,
      getHomeFeed: GetHomeFeed(repository),
    );
  }

  HomeBloc createHomeBloc() => HomeBloc(getHomeFeed: getHomeFeed);
}

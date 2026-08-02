import 'dart:math';

import 'package:admin_dashboard/src/data/datasources/mock_dashboard_analytics_data_source.dart';
import 'package:admin_dashboard/src/data/repositories/mock_analytics_repository_impl.dart';
import 'package:admin_dashboard/src/domain/repositories/analytics_repository.dart';
import 'package:admin_dashboard/src/domain/usecases/get_dashboard_kpis.dart';
import 'package:admin_dashboard/src/presentation/bloc/admin_dashboard_bloc.dart';
import 'package:core/core.dart';

final class AdminDashboardTestHarness {
  AdminDashboardTestHarness._({
    required this.controls,
    required this.store,
    required this.repository,
    required this.getDashboardKpis,
  });

  final MockDeveloperControls controls;
  final MockSeedStore store;
  final AnalyticsRepository repository;
  final GetDashboardKpis getDashboardKpis;

  static AdminDashboardTestHarness create() {
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
    final remote = MockDashboardAnalyticsDataSource(
      simulator: simulator,
      store: store,
    );
    final repository = MockAnalyticsRepositoryImpl(remote);

    return AdminDashboardTestHarness._(
      controls: controls,
      store: store,
      repository: repository,
      getDashboardKpis: GetDashboardKpis(repository),
    );
  }

  AdminDashboardBloc createBloc() =>
      AdminDashboardBloc(getDashboardKpis: getDashboardKpis);
}

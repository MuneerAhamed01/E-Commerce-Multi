import 'package:core/core.dart';

import '../data/datasources/dashboard_analytics_data_source.dart';
import '../data/datasources/mock_dashboard_analytics_data_source.dart';
import '../data/repositories/mock_analytics_repository_impl.dart';
import '../domain/repositories/analytics_repository.dart';
import '../domain/usecases/get_dashboard_kpis.dart';
import '../presentation/bloc/admin_dashboard_bloc.dart';

/// Registers admin dashboard dependencies.
///
/// Call **after** [configureMockInjection]. Safe to call once per process.
void configureAdminDashboardInjection() {
  if (!getIt.isRegistered<MockNetworkSimulator>() ||
      !getIt.isRegistered<MockSeedStore>()) {
    throw StateError(
      'configureAdminDashboardInjection() requires configureMockInjection() '
      'first.',
    );
  }

  if (!getIt.isRegistered<DashboardAnalyticsDataSource>()) {
    getIt.registerLazySingleton<DashboardAnalyticsDataSource>(
      () => MockDashboardAnalyticsDataSource(
        simulator: getIt<MockNetworkSimulator>(),
        store: getIt<MockSeedStore>(),
      ),
    );
  }

  if (!getIt.isRegistered<AnalyticsRepository>()) {
    getIt.registerLazySingleton<AnalyticsRepository>(
      () => MockAnalyticsRepositoryImpl(getIt<DashboardAnalyticsDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetDashboardKpis>()) {
    getIt.registerFactory<GetDashboardKpis>(
      () => GetDashboardKpis(getIt<AnalyticsRepository>()),
    );
  }

  if (!getIt.isRegistered<AdminDashboardBloc>()) {
    getIt.registerFactory<AdminDashboardBloc>(
      () => AdminDashboardBloc(getDashboardKpis: getIt()),
    );
  }
}

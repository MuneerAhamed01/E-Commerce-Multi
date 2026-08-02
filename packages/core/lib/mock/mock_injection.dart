import '../config/app_config.dart';
import '../di/injection_container.dart';
import 'example/get_ping.dart';
import 'example/mock_ping_remote_data_source.dart';
import 'example/mock_ping_repository.dart';
import 'example/ping_remote_data_source.dart';
import 'example/ping_repository.dart';
import 'fixtures/mock_seed_store.dart';
import 'mock_developer_controls.dart';
import 'mock_network_simulator.dart';

/// Registers shared mock infrastructure + the reference ping stack.
///
/// Call **after** [AppConfig] is registered on [getIt] (apps do this in
/// `bootstrap()`). Safe to call once per process; subsequent calls are
/// no-ops when types are already registered.
void configureMockInjection() {
  if (!getIt.isRegistered<AppConfig>()) {
    throw StateError(
      'configureMockInjection() requires AppConfig to be registered first.',
    );
  }

  if (!getIt.isRegistered<MockDeveloperControls>()) {
    getIt.registerLazySingleton<MockDeveloperControls>(
      MockDeveloperControls.new,
    );
  }

  if (!getIt.isRegistered<MockNetworkSimulator>()) {
    getIt.registerLazySingleton<MockNetworkSimulator>(
      () => MockNetworkSimulator(
        appConfig: getIt<AppConfig>(),
        controls: getIt<MockDeveloperControls>(),
      ),
    );
  }

  if (!getIt.isRegistered<MockSeedStore>()) {
    getIt.registerLazySingleton<MockSeedStore>(
      () => MockSeedStore(controls: getIt<MockDeveloperControls>()),
    );
  }

  if (!getIt.isRegistered<PingRemoteDataSource>()) {
    getIt.registerLazySingleton<PingRemoteDataSource>(
      () => MockPingRemoteDataSource(
        simulator: getIt<MockNetworkSimulator>(),
        store: getIt<MockSeedStore>(),
      ),
    );
  }

  if (!getIt.isRegistered<PingRepository>()) {
    getIt.registerLazySingleton<PingRepository>(
      () => MockPingRepository(getIt<PingRemoteDataSource>()),
    );
  }

  if (!getIt.isRegistered<GetPing>()) {
    getIt.registerFactory<GetPing>(() => GetPing(getIt<PingRepository>()));
  }
}

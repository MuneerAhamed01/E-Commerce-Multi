/// Shared mock-data infrastructure (Phase 6).
///
/// - [MockNetworkSimulator] / [MockDataSourceMixin] — latency + failure
/// - [MockDeveloperControls] — Developer Panel toggles + reset listeners
/// - [SeedData] / [MockSeedStore] — cross-feature seed fixtures
/// - `example/` — reference ping stack (domain → mock → repo → use case)
library;

export 'example/get_ping.dart';
export 'example/mock_ping_remote_data_source.dart';
export 'example/mock_ping_repository.dart';
export 'example/ping_message.dart';
export 'example/ping_remote_data_source.dart';
export 'example/ping_repository.dart';
export 'fixtures/fixtures.dart';
export 'mock_call_types.dart';
export 'mock_data_source.dart';
export 'mock_developer_controls.dart';
export 'mock_injection.dart';
export 'mock_network_simulator.dart';

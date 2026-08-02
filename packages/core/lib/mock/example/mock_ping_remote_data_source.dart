import '../fixtures/mock_seed_store.dart';
import '../mock_call_types.dart';
import '../mock_data_source.dart';
import '../mock_network_simulator.dart';
import 'ping_message.dart';
import 'ping_remote_data_source.dart';

/// Canonical mock data source example — latency + failure via
/// [MockDataSourceMixin] (docs/10_DATA_FLOW.md §2).
final class MockPingRemoteDataSource
    with MockDataSourceMixin
    implements PingRemoteDataSource {
  MockPingRemoteDataSource({
    required this.simulator,
    required MockSeedStore store,
  }) : _store = store; // ignore: prefer_initializing_formals

  @override
  final MockNetworkSimulator simulator;

  final MockSeedStore _store;

  @override
  Future<PingMessage> fetchPing() => guarded(MockCallTypes.ping, () async {
    return PingMessage(
      message: 'pong from mock data source',
      productCount: _store.products.length,
      servedAtIso: DateTime.now().toUtc().toIso8601String(),
    );
  });
}

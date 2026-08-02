import 'dart:async';

import 'mock_network_simulator.dart';

/// Mixin that feature mock data sources extend for consistent latency /
/// failure behavior.
///
/// Canonical pattern (docs/10_DATA_FLOW.md §1–2,
/// docs/05_ARCHITECTURE_GUIDELINES.md §6):
///
/// ```dart
/// abstract interface class ProductsRemoteDataSource {
///   Future<List<ProductModel>> fetchProducts();
/// }
///
/// final class MockProductsRemoteDataSource
///     with MockDataSourceMixin
///     implements ProductsRemoteDataSource {
///   MockProductsRemoteDataSource({
///     required this.simulator,
///     required MockSeedStore store,
///   }) : _store = store;
///
///   @override
///   final MockNetworkSimulator simulator;
///
///   final MockSeedStore _store;
///
///   @override
///   Future<List<ProductModel>> fetchProducts() =>
///       guarded('products.list', () async => _store.products);
/// }
/// ```
///
/// Rules:
/// - Mock data sources are plain Dart (no Flutter / no Bloc imports).
/// - They throw [AppException] subtypes on simulated failure; repositories
///   are the only place that catch and map to [Failure].
/// - Fixture data lives in a singleton in-memory store registered via DI,
///   not re-read from disk on every call.
mixin MockDataSourceMixin {
  /// Shared [MockNetworkSimulator] injected via DI.
  MockNetworkSimulator get simulator;

  /// Runs [action] under the shared latency + failure-injection policy.
  Future<T> guarded<T>(String callType, FutureOr<T> Function() action) =>
      simulator.run(callType, action);
}

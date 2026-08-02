import 'package:core/core.dart';

import '../../domain/entities/wishlist_item.dart';
import '../mock/wishlist_call_types.dart';
import '../mock/wishlist_demo_seed.dart';
import 'wishlist_remote_data_source.dart';

/// Process-local wishlist store for unit/widget tests (no SharedPreferences).
final class InMemoryWishlistRemoteDataSource
    with MockDataSourceMixin
    implements WishlistRemoteDataSource {
  InMemoryWishlistRemoteDataSource({
    required this.simulator,
    required MockDeveloperControls controls,
    DateTime Function()? clock,
    Map<String, List<WishlistItem>>? seedByUser,
    // ignore: prefer_initializing_formals
  }) : _controls = controls,
       _clock = clock ?? DateTime.now {
    if (seedByUser != null) {
      for (final entry in seedByUser.entries) {
        _store[entry.key] = List<WishlistItem>.of(entry.value);
      }
    } else {
      _store[WishlistDemoSeed.demoCustomerId] = List<WishlistItem>.of(
        WishlistDemoSeed.demoItems,
      );
    }
    _controls.registerResetListener(_onReset);
  }

  @override
  final MockNetworkSimulator simulator;

  final MockDeveloperControls _controls;
  final DateTime Function() _clock;
  final Map<String, List<WishlistItem>> _store = {};

  void dispose() {
    _controls.unregisterResetListener(_onReset);
  }

  void _onReset() {
    _store
      ..clear()
      ..[WishlistDemoSeed.demoCustomerId] = List<WishlistItem>.of(
        WishlistDemoSeed.demoItems,
      );
  }

  List<WishlistItem> _read(String userId) {
    return List<WishlistItem>.of(_store[userId] ?? const []);
  }

  void _write(String userId, List<WishlistItem> items) {
    _store[userId] = List<WishlistItem>.of(items);
  }

  @override
  Future<List<WishlistItem>> fetchWishlist(String userId) {
    return guarded(WishlistCallTypes.get, () async {
      final items = _read(userId);
      items.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      return items;
    });
  }

  @override
  Future<WishlistItem> addItem({
    required String userId,
    required String productId,
    String? variantId,
  }) {
    return guarded(WishlistCallTypes.add, () async {
      final items = _read(userId);
      final existingIndex = items.indexWhere((e) => e.productId == productId);
      final item = WishlistItem(
        productId: productId,
        variantId: variantId,
        addedAt: _clock().toUtc(),
      );
      if (existingIndex >= 0) {
        items[existingIndex] = item;
      } else {
        items.add(item);
      }
      _write(userId, items);
      return item;
    });
  }

  @override
  Future<void> removeItem({required String userId, required String productId}) {
    return guarded(WishlistCallTypes.remove, () async {
      final items = _read(userId)..removeWhere((e) => e.productId == productId);
      _write(userId, items);
    });
  }

  @override
  Future<bool> contains({required String userId, required String productId}) {
    return guarded(WishlistCallTypes.contains, () async {
      return _read(userId).any((e) => e.productId == productId);
    });
  }
}

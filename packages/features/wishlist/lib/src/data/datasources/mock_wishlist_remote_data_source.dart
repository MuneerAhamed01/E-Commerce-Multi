import 'dart:convert';

import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/wishlist_item.dart';
import '../mock/wishlist_call_types.dart';
import '../mock/wishlist_demo_seed.dart';
import 'wishlist_remote_data_source.dart';

/// SharedPreferences-backed wishlist with mock network shaping.
///
/// Keys are per-user (`wishlist.<userId>`). Demo customer
/// [WishlistDemoSeed.demoCustomerId] is pre-seeded when no key exists yet.
final class MockWishlistRemoteDataSource
    with MockDataSourceMixin
    implements WishlistRemoteDataSource {
  MockWishlistRemoteDataSource({
    required this.simulator,
    required SharedPreferences preferences,
    required MockDeveloperControls controls,
    DateTime Function()? clock,
    // ignore: prefer_initializing_formals
  }) : _prefs = preferences,
       // ignore: prefer_initializing_formals
       _controls = controls,
       _clock = clock ?? DateTime.now {
    _controls.registerResetListener(_onReset);
  }

  @override
  final MockNetworkSimulator simulator;

  final SharedPreferences _prefs;
  final MockDeveloperControls _controls;
  final DateTime Function() _clock;

  static const String _keyPrefix = 'wishlist.';

  /// In-process mirror so rapid toggles stay consistent within a session.
  final Map<String, List<WishlistItem>> _cache = {};

  void dispose() {
    _controls.unregisterResetListener(_onReset);
  }

  void _onReset() {
    _cache.clear();
    final keys = _prefs
        .getKeys()
        .where((k) => k.startsWith(_keyPrefix))
        .toList();
    for (final key in keys) {
      _prefs.remove(key);
    }
    // Re-seed demo customer for QA after reset.
    _writeUser(
      WishlistDemoSeed.demoCustomerId,
      List<WishlistItem>.of(WishlistDemoSeed.demoItems),
    );
  }

  String _key(String userId) => '$_keyPrefix$userId';

  List<WishlistItem> _readUser(String userId) {
    final cached = _cache[userId];
    if (cached != null) {
      return List<WishlistItem>.of(cached);
    }

    final raw = _prefs.getString(_key(userId));
    if (raw == null) {
      if (userId == WishlistDemoSeed.demoCustomerId) {
        final seeded = List<WishlistItem>.of(WishlistDemoSeed.demoItems);
        _writeUser(userId, seeded);
        return List<WishlistItem>.of(seeded);
      }
      _cache[userId] = [];
      return [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        _cache[userId] = [];
        return [];
      }
      final items = decoded
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => WishlistItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      _cache[userId] = items;
      return List<WishlistItem>.of(items);
    } on Object catch (e) {
      throw CacheException('Failed to read wishlist for $userId: $e');
    }
  }

  void _writeUser(String userId, List<WishlistItem> items) {
    _cache[userId] = List<WishlistItem>.of(items);
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    // SharedPreferences.setString is sync enough for mock; ignore bool result.
    _prefs.setString(_key(userId), encoded);
  }

  @override
  Future<List<WishlistItem>> fetchWishlist(String userId) {
    return guarded(WishlistCallTypes.get, () async {
      final items = _readUser(userId);
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
      final items = _readUser(userId);
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
      _writeUser(userId, items);
      return item;
    });
  }

  @override
  Future<void> removeItem({required String userId, required String productId}) {
    return guarded(WishlistCallTypes.remove, () async {
      final items = _readUser(userId)
        ..removeWhere((e) => e.productId == productId);
      _writeUser(userId, items);
    });
  }

  @override
  Future<bool> contains({required String userId, required String productId}) {
    return guarded(WishlistCallTypes.contains, () async {
      return _readUser(userId).any((e) => e.productId == productId);
    });
  }
}

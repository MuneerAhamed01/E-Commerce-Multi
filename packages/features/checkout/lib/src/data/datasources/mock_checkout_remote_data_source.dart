import 'dart:convert';

import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/checkout_payment_method.dart';
import '../../domain/entities/saved_address.dart';
import '../../domain/entities/shipping_method.dart';
import '../mock/checkout_call_types.dart';
import '../mock/checkout_demo_seed.dart';
import '../mock/checkout_shipping_catalog.dart';
import 'checkout_remote_data_source.dart';

/// SharedPreferences address book + local shipping/payment catalogs.
final class MockCheckoutRemoteDataSource
    with MockDataSourceMixin
    implements CheckoutRemoteDataSource {
  MockCheckoutRemoteDataSource({
    required this.simulator,
    required SharedPreferences preferences,
    required MockDeveloperControls controls,
    // ignore: prefer_initializing_formals
  }) : _prefs = preferences,
       // ignore: prefer_initializing_formals
       _controls = controls {
    _controls.registerResetListener(_onReset);
  }

  @override
  final MockNetworkSimulator simulator;

  final SharedPreferences _prefs;
  final MockDeveloperControls _controls;

  static const String _keyPrefix = 'checkout.addresses.';

  final Map<String, List<SavedAddress>> _cache = {};

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
    _writeUser(
      CheckoutDemoSeed.demoCustomerId,
      List<SavedAddress>.of(CheckoutDemoSeed.demoAddresses),
    );
  }

  String _key(String userId) => '$_keyPrefix$userId';

  List<SavedAddress> _readUser(String userId) {
    final cached = _cache[userId];
    if (cached != null) {
      return List<SavedAddress>.of(cached);
    }

    final raw = _prefs.getString(_key(userId));
    if (raw == null) {
      if (userId == CheckoutDemoSeed.demoCustomerId) {
        final seeded = List<SavedAddress>.of(CheckoutDemoSeed.demoAddresses);
        _writeUser(userId, seeded);
        return List<SavedAddress>.of(seeded);
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
          .map((e) => SavedAddress.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      _cache[userId] = items;
      return List<SavedAddress>.of(items);
    } on Object catch (e) {
      throw CacheException('Failed to read addresses for $userId: $e');
    }
  }

  void _writeUser(String userId, List<SavedAddress> items) {
    _cache[userId] = List<SavedAddress>.of(items);
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    _prefs.setString(_key(userId), encoded);
  }

  @override
  Future<List<SavedAddress>> fetchSavedAddresses(String userId) {
    return guarded(CheckoutCallTypes.addressesGet, () async {
      final items = _readUser(userId);
      items.sort((a, b) {
        if (a.isDefault != b.isDefault) {
          return a.isDefault ? -1 : 1;
        }
        return (a.address.label ?? '').compareTo(b.address.label ?? '');
      });
      return items;
    });
  }

  @override
  Future<SavedAddress> saveAddress({
    required String userId,
    required Address address,
    bool makeDefault = false,
  }) {
    return guarded(CheckoutCallTypes.addressesSave, () async {
      if (address.line1.trim().isEmpty ||
          address.city.trim().isEmpty ||
          address.state.trim().isEmpty ||
          address.postalCode.trim().isEmpty) {
        throw const ValidationException({
          'address': 'Complete all required address fields',
        }, 'Invalid address');
      }
      final items = _readUser(userId);
      final id =
          'addr_${DateTime.now().toUtc().millisecondsSinceEpoch}_${items.length}';
      final isDefault = makeDefault || items.isEmpty;
      var next = List<SavedAddress>.of(items);
      if (isDefault) {
        next = next
            .map((e) => e.copyWith(isDefault: false))
            .toList(growable: true);
      }
      final saved = SavedAddress(
        id: id,
        address: address,
        isDefault: isDefault,
      );
      next.add(saved);
      _writeUser(userId, next);
      return saved;
    });
  }

  @override
  Future<List<ShippingMethod>> fetchShippingMethods() {
    return guarded(CheckoutCallTypes.shippingList, () async {
      return List<ShippingMethod>.of(CheckoutShippingCatalog.methods);
    });
  }

  @override
  Future<Money> calculateShippingCost({
    required String methodId,
    required String postalCode,
  }) {
    return guarded(CheckoutCallTypes.shippingCost, () async {
      if (postalCode.trim() == CheckoutShippingCatalog.unavailablePostalCode) {
        throw const ValidationException({
          'postalCode': 'Shipping is unavailable for this postal code',
        }, 'Shipping unavailable');
      }
      final method = CheckoutShippingCatalog.byId(methodId);
      if (method == null) {
        throw NotFoundException('Shipping method not found: $methodId');
      }
      return method.cost;
    });
  }

  @override
  Future<List<CheckoutPaymentMethod>> fetchPaymentMethods(String userId) {
    return guarded(CheckoutCallTypes.paymentsList, () async {
      // In-memory constant list (prefs optional — Phase 16 owns real methods).
      return List<CheckoutPaymentMethod>.of(CheckoutDemoSeed.paymentMethods);
    });
  }
}

import 'dart:convert';

import 'package:core/core.dart';
import 'package:products/products.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/promo_definition.dart';
import '../../domain/pricing/cart_pricing_engine.dart';
import '../../domain/promo/cart_promo_catalog.dart';
import '../mock/cart_call_types.dart';
import 'cart_remote_data_source.dart';

/// SharedPreferences-backed cart with mock network shaping.
///
/// Keys are per-owner (`cart.<ownerId>`). Empty by default. Product price /
/// stock resolved via [GetProductDetail]. Promo codes from local
/// [CartPromoCatalog] (Marketing deviation).
final class MockCartRemoteDataSource
    with MockDataSourceMixin
    implements CartRemoteDataSource {
  MockCartRemoteDataSource({
    required this.simulator,
    required SharedPreferences preferences,
    required MockDeveloperControls controls,
    required GetProductDetail getProductDetail,
    DateTime Function()? clock,
    Map<String, PromoDefinition>? promoCatalog,
    // ignore: prefer_initializing_formals
  }) : _prefs = preferences,
       // ignore: prefer_initializing_formals
       _controls = controls,
       // ignore: prefer_initializing_formals
       _getProductDetail = getProductDetail,
       _clock = clock ?? DateTime.now,
       _promoCatalog =
           promoCatalog ?? CartPromoCatalog.definitions(clock: clock) {
    _controls.registerResetListener(_onReset);
  }

  @override
  final MockNetworkSimulator simulator;

  final SharedPreferences _prefs;
  final MockDeveloperControls _controls;
  final GetProductDetail _getProductDetail;
  final DateTime Function() _clock;
  final Map<String, PromoDefinition> _promoCatalog;

  static const String _keyPrefix = 'cart.';

  final Map<String, Cart> _cache = {};

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
  }

  String _key(String ownerId) => '$_keyPrefix$ownerId';

  Cart _read(String ownerId) {
    final cached = _cache[ownerId];
    if (cached != null) {
      return cached;
    }
    final raw = _prefs.getString(_key(ownerId));
    if (raw == null) {
      final empty = Cart.empty(ownerId);
      _cache[ownerId] = empty;
      return empty;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        final empty = Cart.empty(ownerId);
        _cache[ownerId] = empty;
        return empty;
      }
      final cart = Cart.fromJson(Map<String, dynamic>.from(decoded));
      _cache[ownerId] = cart;
      return cart;
    } on Object catch (e) {
      throw CacheException('Failed to read cart for $ownerId: $e');
    }
  }

  void _write(Cart cart) {
    _cache[cart.ownerId] = cart;
    _prefs.setString(_key(cart.ownerId), jsonEncode(cart.toJson()));
  }

  Future<({Product product, ProductVariant variant})> _loadProduct({
    required String productId,
    required String variantId,
  }) async {
    final result = await _getProductDetail(GetProductDetailParams(productId));
    return result.fold(
      onFailure: (failure) {
        if (failure is NotFoundFailure) {
          throw NotFoundException(failure.message ?? 'Product not found');
        }
        throw ServerException(failure.message ?? 'Could not load product');
      },
      onSuccess: (product) {
        final variant = product.variantById(variantId);
        if (variant == null) {
          throw NotFoundException('Variant $variantId not found');
        }
        return (product: product, variant: variant);
      },
    );
  }

  CartItem _toLine({
    required Product product,
    required ProductVariant variant,
    required int quantity,
  }) {
    final imageUrl = variant.imageUrl.isNotEmpty
        ? variant.imageUrl
        : (product.images.isNotEmpty ? product.images.first.url : '');
    return CartItem(
      productId: product.id,
      variantId: variant.id,
      productName: product.name,
      variantLabel: variant.label,
      unitPrice: variant.price,
      quantity: quantity,
      maxStock: variant.stock,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<Cart> fetchCart(String ownerId) {
    return guarded(CartCallTypes.get, () async {
      final cart = _read(ownerId);
      return _revalidateStock(cart);
    });
  }

  Future<Cart> _revalidateStock(Cart cart) async {
    if (cart.items.isEmpty) {
      return cart;
    }
    final adjusted = <CartItem>[];
    var changed = false;
    for (final item in cart.items) {
      try {
        final loaded = await _loadProduct(
          productId: item.productId,
          variantId: item.variantId,
        );
        final stock = loaded.variant.stock;
        if (stock < 1) {
          changed = true;
          continue;
        }
        var qty = item.quantity;
        if (qty > stock) {
          qty = stock;
          changed = true;
        }
        adjusted.add(
          _toLine(
            product: loaded.product,
            variant: loaded.variant,
            quantity: qty,
          ),
        );
        if (item.unitPrice != loaded.variant.price ||
            item.maxStock != stock ||
            item.productName != loaded.product.name) {
          changed = true;
        }
      } on NotFoundException {
        changed = true;
      }
    }

    var next = cart.copyWith(items: adjusted);
    if (next.appliedPromoCode != null) {
      final validation = PromoValidator.validate(
        rawCode: next.appliedPromoCode!,
        subtotal: next.subtotal,
        catalog: _promoCatalog,
        clock: _clock,
      );
      if (validation is PromoValidationFailure) {
        next = next.copyWith(clearPromo: true);
        changed = true;
      }
    }
    if (changed) {
      _write(next);
    }
    return next;
  }

  @override
  Future<Cart> addItem({
    required String ownerId,
    required String productId,
    required String variantId,
    required int quantity,
  }) {
    return guarded(CartCallTypes.add, () async {
      if (quantity < 1) {
        throw const ValidationException({
          'quantity': 'Quantity must be at least 1',
        }, 'Zero quantity is not allowed');
      }

      final loaded = await _loadProduct(
        productId: productId,
        variantId: variantId,
      );
      final stock = loaded.variant.stock;
      if (stock < 1) {
        throw const ValidationException({
          'quantity': 'Out of stock',
        }, 'This item is out of stock');
      }

      final cart = _read(ownerId);
      final existing = cart.itemFor(productId: productId, variantId: variantId);
      final desired = (existing?.quantity ?? 0) + quantity;
      if (desired > stock) {
        throw ValidationException({
          'quantity': 'Only $stock available',
        }, 'Quantity exceeds available stock ($stock)');
      }

      final line = _toLine(
        product: loaded.product,
        variant: loaded.variant,
        quantity: desired,
      );
      final items = List<CartItem>.of(cart.items);
      final index = items.indexWhere((e) => e.lineKey == line.lineKey);
      if (index >= 0) {
        items[index] = line;
      } else {
        items.add(line);
      }
      final next = cart.copyWith(items: items);
      _write(next);
      return next;
    });
  }

  @override
  Future<Cart> updateQuantity({
    required String ownerId,
    required String productId,
    required String variantId,
    required int quantity,
  }) {
    return guarded(CartCallTypes.update, () async {
      final cart = _read(ownerId);
      final existing = cart.itemFor(productId: productId, variantId: variantId);
      if (existing == null) {
        throw const NotFoundException('Cart line not found');
      }

      final loaded = await _loadProduct(
        productId: productId,
        variantId: variantId,
      );
      final stock = loaded.variant.stock;
      final qtyError = CartPricingEngine.validateQuantity(
        quantity: quantity,
        maxStock: stock,
      );
      if (qtyError != null) {
        if (quantity > stock && stock >= 0) {
          throw ValidationException({
            'quantity': 'Only $stock available',
          }, qtyError.message);
        }
        throw ValidationException(qtyError.fieldErrors, qtyError.message);
      }

      final line = _toLine(
        product: loaded.product,
        variant: loaded.variant,
        quantity: quantity,
      );
      final items = cart.items
          .map((e) => e.lineKey == line.lineKey ? line : e)
          .toList();
      final next = cart.copyWith(items: items);
      _write(next);
      return next;
    });
  }

  @override
  Future<Cart> removeItem({
    required String ownerId,
    required String productId,
    required String variantId,
  }) {
    return guarded(CartCallTypes.remove, () async {
      final cart = _read(ownerId);
      final key = '$productId::$variantId';
      final items = cart.items.where((e) => e.lineKey != key).toList();
      final next = items.isEmpty
          ? cart.copyWith(items: items, clearPromo: true)
          : cart.copyWith(items: items);
      _write(next);
      return next;
    });
  }

  @override
  Future<Cart> clearCart(String ownerId) {
    return guarded(CartCallTypes.clear, () async {
      final next = Cart.empty(ownerId);
      _write(next);
      return next;
    });
  }

  @override
  Future<Cart> applyPromoCode({required String ownerId, required String code}) {
    return guarded(CartCallTypes.applyPromo, () async {
      final cart = _read(ownerId);
      if (cart.isEmpty) {
        throw const ValidationException({
          'promoCode': 'Add items before applying a promo',
        }, 'Cart is empty');
      }

      // Single-promo policy: replace any existing code after validation.
      final validation = PromoValidator.validate(
        rawCode: code,
        subtotal: cart.subtotal,
        catalog: _promoCatalog,
        clock: _clock,
      );
      if (validation is PromoValidationFailure) {
        throw ValidationException({
          'promoCode': validation.message,
        }, validation.message);
      }
      final promo = (validation as PromoValidationSuccess).promo;
      final next = cart.copyWith(appliedPromoCode: promo.code);
      _write(next);
      return next;
    });
  }

  @override
  Future<Cart> removePromoCode(String ownerId) {
    return guarded(CartCallTypes.removePromo, () async {
      final cart = _read(ownerId);
      final next = cart.copyWith(clearPromo: true);
      _write(next);
      return next;
    });
  }

  @override
  Future<Cart> mergeGuestCart({
    required String guestOwnerId,
    required String userOwnerId,
  }) {
    return guarded(CartCallTypes.merge, () async {
      final guest = _read(guestOwnerId);
      var user = _read(userOwnerId);

      for (final item in guest.items) {
        final existing = user.itemFor(
          productId: item.productId,
          variantId: item.variantId,
        );
        final combinedQty = (existing?.quantity ?? 0) + item.quantity;
        final capped = CartPricingEngine.capQuantity(
          combinedQty,
          item.maxStock,
        );
        if (capped < 1) {
          continue;
        }
        final line = item.copyWith(quantity: capped);
        final items = List<CartItem>.of(user.items);
        final index = items.indexWhere((e) => e.lineKey == line.lineKey);
        if (index >= 0) {
          items[index] = line;
        } else {
          items.add(line);
        }
        user = user.copyWith(items: items);
      }

      if (user.appliedPromoCode == null && guest.appliedPromoCode != null) {
        user = user.copyWith(appliedPromoCode: guest.appliedPromoCode);
      }

      _write(user);
      _write(Cart.empty(guestOwnerId));
      return user;
    });
  }
}

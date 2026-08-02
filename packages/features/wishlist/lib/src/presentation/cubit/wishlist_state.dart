import 'package:equatable/equatable.dart';
import 'package:products/products.dart';

import '../../domain/entities/wishlist_item.dart';

sealed class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

/// Before the first auth-driven load.
final class WishlistInitial extends WishlistState {
  const WishlistInitial();
}

/// Guest session — no membership data.
final class WishlistGuest extends WishlistState {
  const WishlistGuest();
}

final class WishlistLoading extends WishlistState {
  const WishlistLoading();
}

final class WishlistLoaded extends WishlistState {
  const WishlistLoaded({
    required this.userId,
    required this.items,
    required this.products,
    this.pendingProductId,
    this.isToggling = false,
  });

  final String userId;
  final List<WishlistItem> items;

  /// Resolved catalog products keyed by product id (missing ids omitted).
  final Map<String, Product> products;

  /// Product queued for toggle after login (guest path).
  final String? pendingProductId;

  final bool isToggling;

  Set<String> get productIds => {for (final item in items) item.productId};

  bool contains(String productId) => productIds.contains(productId);

  List<Product> get orderedProducts {
    final result = <Product>[];
    for (final item in items) {
      final product = products[item.productId];
      if (product != null) {
        result.add(product);
      }
    }
    return result;
  }

  WishlistLoaded copyWith({
    String? userId,
    List<WishlistItem>? items,
    Map<String, Product>? products,
    String? pendingProductId,
    bool clearPending = false,
    bool? isToggling,
  }) {
    return WishlistLoaded(
      userId: userId ?? this.userId,
      items: items ?? this.items,
      products: products ?? this.products,
      pendingProductId: clearPending
          ? null
          : (pendingProductId ?? this.pendingProductId),
      isToggling: isToggling ?? this.isToggling,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    items,
    products,
    pendingProductId,
    isToggling,
  ];
}

final class WishlistError extends WishlistState {
  const WishlistError(this.message, {this.userId});

  final String message;
  final String? userId;

  @override
  List<Object?> get props => [message, userId];
}

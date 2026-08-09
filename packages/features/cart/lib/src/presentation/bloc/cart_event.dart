import 'package:equatable/equatable.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

final class CartStarted extends CartEvent {
  const CartStarted();
}

final class CartRetried extends CartEvent {
  const CartRetried();
}

final class CartItemAdded extends CartEvent {
  const CartItemAdded({
    required this.productId,
    required this.variantId,
    this.quantity = 1,
  });

  final String productId;
  final String variantId;
  final int quantity;

  @override
  List<Object?> get props => [productId, variantId, quantity];
}

final class CartQuantityChanged extends CartEvent {
  const CartQuantityChanged({
    required this.productId,
    required this.variantId,
    required this.quantity,
  });

  final String productId;
  final String variantId;
  final int quantity;

  @override
  List<Object?> get props => [productId, variantId, quantity];
}

final class CartItemRemoved extends CartEvent {
  const CartItemRemoved({required this.productId, required this.variantId});

  final String productId;
  final String variantId;

  @override
  List<Object?> get props => [productId, variantId];
}

final class CartCleared extends CartEvent {
  const CartCleared();
}

final class CartPromoApplied extends CartEvent {
  const CartPromoApplied(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

final class CartPromoRemoved extends CartEvent {
  const CartPromoRemoved();
}

final class CartCheckoutPressed extends CartEvent {
  const CartCheckoutPressed();
}

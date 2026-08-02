part of 'product_detail_bloc.dart';

sealed class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object?> get props => [];
}

final class ProductDetailStarted extends ProductDetailEvent {
  const ProductDetailStarted(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

final class ProductDetailRetried extends ProductDetailEvent {
  const ProductDetailRetried();
}

final class ProductVariantSelected extends ProductDetailEvent {
  const ProductVariantSelected(this.variantId);

  final String variantId;

  @override
  List<Object?> get props => [variantId];
}

final class ProductAddToCartPressed extends ProductDetailEvent {
  const ProductAddToCartPressed();
}

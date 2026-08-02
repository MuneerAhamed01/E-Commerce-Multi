part of 'product_detail_bloc.dart';

sealed class ProductDetailState extends Equatable {
  const ProductDetailState();

  @override
  List<Object?> get props => [];
}

final class ProductDetailInitial extends ProductDetailState {
  const ProductDetailInitial();
}

final class ProductDetailLoading extends ProductDetailState {
  const ProductDetailLoading();
}

final class ProductDetailLoaded extends ProductDetailState {
  const ProductDetailLoaded({
    required this.product,
    required this.selectedVariantId,
    required this.relatedProducts,
    this.statusMessage,
  });

  final Product product;
  final String selectedVariantId;
  final List<Product> relatedProducts;

  /// Transient snackbar / inline message (OOS block, coming soon).
  final String? statusMessage;

  ProductVariant get selectedVariant =>
      product.variantById(selectedVariantId) ?? product.defaultVariant;

  bool get canAddToCart => selectedVariant.isInStock;

  ProductDetailLoaded copyWith({
    Product? product,
    String? selectedVariantId,
    List<Product>? relatedProducts,
    String? statusMessage,
    bool clearStatusMessage = false,
  }) {
    return ProductDetailLoaded(
      product: product ?? this.product,
      selectedVariantId: selectedVariantId ?? this.selectedVariantId,
      relatedProducts: relatedProducts ?? this.relatedProducts,
      statusMessage: clearStatusMessage
          ? null
          : (statusMessage ?? this.statusMessage),
    );
  }

  @override
  List<Object?> get props => [
    product,
    selectedVariantId,
    relatedProducts,
    statusMessage,
  ];
}

final class ProductDetailError extends ProductDetailState {
  const ProductDetailError(this.message, {this.productId});

  final String message;
  final String? productId;

  @override
  List<Object?> get props => [message, productId];
}

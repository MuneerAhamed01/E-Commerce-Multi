import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/usecases/get_product_detail.dart';
import '../../domain/usecases/get_related_products.dart';

part 'product_detail_event.dart';
part 'product_detail_state.dart';

/// Loads product detail + related items; tracks selected variant.
final class ProductDetailBloc
    extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc({
    required this.getProductDetail,
    required this.getRelatedProducts,
  }) : super(const ProductDetailInitial()) {
    on<ProductDetailStarted>(_onStarted);
    on<ProductDetailRetried>(_onRetried);
    on<ProductVariantSelected>(_onVariantSelected);
    on<ProductAddToCartPressed>(_onAddToCart);
  }

  final GetProductDetail getProductDetail;
  final GetRelatedProducts getRelatedProducts;

  String? _productId;

  Future<void> _onStarted(
    ProductDetailStarted event,
    Emitter<ProductDetailState> emit,
  ) async {
    _productId = event.productId;
    await _load(emit);
  }

  Future<void> _onRetried(
    ProductDetailRetried event,
    Emitter<ProductDetailState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<ProductDetailState> emit) async {
    final productId = _productId;
    if (productId == null || productId.isEmpty) {
      emit(const ProductDetailError('Missing product id'));
      return;
    }

    emit(const ProductDetailLoading());
    final detailResult = await getProductDetail(
      GetProductDetailParams(productId),
    );
    if (detailResult.isFailure) {
      emit(
        ProductDetailError(
          _mapFailure(detailResult.failureOrNull!),
          productId: productId,
        ),
      );
      return;
    }

    final product = detailResult.valueOrNull!;
    final relatedResult = await getRelatedProducts(
      GetRelatedProductsParams(productId: productId),
    );
    final related = relatedResult.fold(
      onFailure: (_) => const <Product>[],
      onSuccess: (page) => page.items,
    );
    emit(
      ProductDetailLoaded(
        product: product,
        selectedVariantId: product.defaultVariant.id,
        relatedProducts: related,
      ),
    );
  }

  void _onVariantSelected(
    ProductVariantSelected event,
    Emitter<ProductDetailState> emit,
  ) {
    final current = state;
    if (current is! ProductDetailLoaded) {
      return;
    }
    if (current.product.variantById(event.variantId) == null) {
      return;
    }
    emit(
      current.copyWith(
        selectedVariantId: event.variantId,
        clearStatusMessage: true,
      ),
    );
  }

  void _onAddToCart(
    ProductAddToCartPressed event,
    Emitter<ProductDetailState> emit,
  ) {
    final current = state;
    if (current is! ProductDetailLoaded) {
      return;
    }
    if (!current.canAddToCart) {
      emit(current.copyWith(statusMessage: 'This variant is out of stock'));
      return;
    }
    emit(
      current.copyWith(
        statusMessage: 'Coming soon — cart is not available yet',
      ),
    );
  }

  String _mapFailure(Failure failure) {
    if (failure is NotFoundFailure) {
      return failure.message ?? 'Product not found';
    }
    return failure.message ??
        'Unable to load this product right now. Please try again.';
  }
}

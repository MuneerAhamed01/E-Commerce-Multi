import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/entities/product_page_request.dart';
import '../../domain/usecases/get_products.dart';

part 'product_list_event.dart';
part 'product_list_state.dart';

/// Paginated product catalog with optional category filter.
final class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  ProductListBloc({required this.getProducts})
    : super(const ProductListInitial()) {
    on<ProductListStarted>(_onStarted);
    on<ProductListRetried>(_onRetried);
    on<ProductListLoadMore>(_onLoadMore);
    on<ProductListCategoryChanged>(_onCategoryChanged);
  }

  final GetProducts getProducts;

  String? _categoryId;
  String? _nextCursor;

  Future<void> _onStarted(
    ProductListStarted event,
    Emitter<ProductListState> emit,
  ) async {
    _categoryId = event.categoryId;
    await _loadFirstPage(emit);
  }

  Future<void> _onRetried(
    ProductListRetried event,
    Emitter<ProductListState> emit,
  ) async {
    await _loadFirstPage(emit);
  }

  Future<void> _onCategoryChanged(
    ProductListCategoryChanged event,
    Emitter<ProductListState> emit,
  ) async {
    _categoryId = event.categoryId;
    await _loadFirstPage(emit);
  }

  Future<void> _loadFirstPage(Emitter<ProductListState> emit) async {
    emit(const ProductListLoading());
    _nextCursor = null;
    final result = await getProducts(
      GetProductsParams(page: const ProductPageRequest(), filter: _filter),
    );
    result.fold(
      onFailure: (failure) =>
          emit(ProductListError(_mapFailure(failure), categoryId: _categoryId)),
      onSuccess: (page) {
        _nextCursor = page.nextPageCursor;
        emit(
          ProductListLoaded(
            products: page.items,
            hasNextPage: page.hasNextPage,
            categoryId: _categoryId,
            totalCount: page.totalCount,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMore(
    ProductListLoadMore event,
    Emitter<ProductListState> emit,
  ) async {
    final current = state;
    if (current is! ProductListLoaded) {
      return;
    }
    if (!current.hasNextPage || current.isLoadingMore || _nextCursor == null) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true, clearLoadMoreError: true));
    final result = await getProducts(
      GetProductsParams(
        page: ProductPageRequest(cursor: _nextCursor),
        filter: _filter,
      ),
    );
    result.fold(
      onFailure: (failure) => emit(
        current.copyWith(
          isLoadingMore: false,
          loadMoreError: _mapFailure(failure),
        ),
      ),
      onSuccess: (page) {
        _nextCursor = page.nextPageCursor;
        emit(
          ProductListLoaded(
            products: [...current.products, ...page.items],
            hasNextPage: page.hasNextPage,
            categoryId: _categoryId,
            totalCount: page.totalCount,
          ),
        );
      },
    );
  }

  ProductFilter? get _filter {
    final id = _categoryId;
    if (id == null || id.isEmpty) {
      return null;
    }
    return ProductFilter(categoryId: id);
  }

  String _mapFailure(Failure failure) {
    return failure.message ??
        'Unable to load products right now. Please try again.';
  }
}

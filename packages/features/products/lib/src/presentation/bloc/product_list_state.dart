part of 'product_list_bloc.dart';

sealed class ProductListState extends Equatable {
  const ProductListState();

  @override
  List<Object?> get props => [];
}

final class ProductListInitial extends ProductListState {
  const ProductListInitial();
}

final class ProductListLoading extends ProductListState {
  const ProductListLoading();
}

final class ProductListLoaded extends ProductListState {
  const ProductListLoaded({
    required this.products,
    required this.hasNextPage,
    this.categoryId,
    this.isLoadingMore = false,
    this.loadMoreError,
    this.totalCount,
  });

  final List<Product> products;
  final bool hasNextPage;
  final String? categoryId;
  final bool isLoadingMore;
  final String? loadMoreError;
  final int? totalCount;

  ProductListLoaded copyWith({
    List<Product>? products,
    bool? hasNextPage,
    String? categoryId,
    bool? isLoadingMore,
    String? loadMoreError,
    int? totalCount,
    bool clearLoadMoreError = false,
  }) {
    return ProductListLoaded(
      products: products ?? this.products,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      categoryId: categoryId ?? this.categoryId,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: clearLoadMoreError
          ? null
          : (loadMoreError ?? this.loadMoreError),
      totalCount: totalCount ?? this.totalCount,
    );
  }

  @override
  List<Object?> get props => [
    products,
    hasNextPage,
    categoryId,
    isLoadingMore,
    loadMoreError,
    totalCount,
  ];
}

final class ProductListError extends ProductListState {
  const ProductListError(this.message, {this.categoryId});

  final String message;
  final String? categoryId;

  @override
  List<Object?> get props => [message, categoryId];
}
